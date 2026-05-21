//
//  ImageEditorViewModel.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 08/05/26.
//

import UIKit
import CoreImage

enum EditingMode {
    case Filter
    case Adjustment
}

final class ImageEditorViewModel {

    //    Callbacks
    var onPreviewImageUpdated: ((UIImage?) -> Void)?

    //    Editing Mode
    var currentMode: EditingMode = .Filter

    //    Source
    let filters: [ImageFilterable] = FilterRegistry.all
    let adjustments: [ImageAdjustable] = AdjustmentRegistry.all

    //   Current Selection
    var selectedFilter: ImageFilterable? = OriginalFilter()
    var selectedAdjustment: ImageAdjustable?

    //    Thumbnail Cache
    private var filterThumbnails: [String: UIImage] = [:]


    //    Editor State
    private(set) var editorState = EditorState()

    //  History
    private var undoStack: [EditorState] = []
    private var redoStack: [EditorState] = []

    //    Rendering
    private var renderTask: DispatchWorkItem?
    private var debounceWorkItem: DispatchWorkItem?
    private let renderQueue = DispatchQueue(label: "image.enhancer.render.queue", qos: .userInitiated)

    //    Images
    private var originalCIImage: CIImage?
    private var previewCIImage: CIImage?
    private(set) var previewImage: UIImage? {
        didSet {
            onPreviewImageUpdated?(previewImage)
        }
    }


    init() {

    }

    func setOriginalImage(image: UIImage) {

        guard let cgImage = image.cgImage else {
            return
        }

        let ciImage = CIImage(cgImage: cgImage)
        originalCIImage = ciImage

        previewCIImage = ciImage.downsampled(maxDimension: 1500)
        previewImage = image
        generateFilterThumbnails() // Thumbnail Generation
    }

    func resetEditor() {

        editorState = EditorState()

        //        undoStack.removeAll()
        //        redoStack.removeAll()

        selectedFilter = nil
        selectedAdjustment = nil
    }

    func scheduleRender() {

        debounceWorkItem?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.render()
        }
        debounceWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: task)
    }


    //    MARK: Filters

    func selectFilter(_ filter: ImageFilterable?) {

        selectedFilter = filter
        editorState.selectedFilterID = filter?.id
        scheduleRender()
    }

    func updateFilterIntensity(_ value: Float) {

        guard let selectedFilter else {
            return
        }

        saveHistory()
        editorState.filterIntensityMap[selectedFilter.id] = value
        scheduleRender()
    }

    func currentFilterIntensity(for filter: ImageFilterable) -> Float {

        editorState.filterIntensityMap[filter.id] ?? filter .defaultIntensity
    }

    func isSelected(_ filter: ImageFilterable) -> Bool {
        return selectedFilter?.id == filter.id
    }

    //    MARK: Adjustments
    func selectAdjustment(_ adjustment: ImageAdjustable) {
        selectedAdjustment = adjustment
    }

    func updateAdjustment(value: Float) {

        guard let selectedAdjustment else {
            return
        }
        saveHistory()
        editorState.adjustmentIntensityMap[selectedAdjustment.id] = value
        scheduleRender()
    }

    func currentAdjustmentIntensity(for adjustment: ImageAdjustable) -> Float {

        editorState.adjustmentIntensityMap[adjustment.id] ?? adjustment.defaultValue
    }

    func isSelected(_ adjustment: ImageAdjustable) -> Bool {
        return selectedAdjustment?.id == adjustment.id
    }
}

//MARK: Undo/ Redo
extension ImageEditorViewModel {

    func undo() {

        guard let previous = undoStack.popLast() else {
            return
        }

        redoStack.append(editorState)
        editorState = previous
        restoreSelections()
        render()
    }

    func redo() {

        guard let next = redoStack.popLast() else {
            return
        }

        undoStack.append(editorState)
        editorState = next
        restoreSelections()
        render()
    }

    func saveHistory() {

        undoStack.append(editorState)
        redoStack.removeAll()
    }

    func restoreSelections() {
        selectedFilter = filters.first {$0.id == editorState.selectedFilterID}
    }
}


//MARK: Image Rendering
private extension ImageEditorViewModel {

    func render() {

        guard let previewCIImage else {
            return
        }

        renderTask?.cancel()

        var task: DispatchWorkItem?
        task = DispatchWorkItem { [weak self] in
            guard let self else {
                return
            }
            let image = ImageRenderer.shared.render(image: previewCIImage,
                                                    state: editorState,
                                                    filters: filters,
                                                    adjustments: adjustments)
            if task?.isCancelled == true {
                return
            }
            DispatchQueue.main.async {
                self.previewImage = image
            }
        }

        guard let task else { return }
        renderTask = task
        renderQueue.async(execute: task)
    }
}

//MARK: Thumbnail Generator

extension ImageEditorViewModel {

    func generateFilterThumbnails() {

        guard let previewCIImage else {
            return
        }

        let dispatchGroup = DispatchGroup()
        filters.forEach { filter in
            dispatchGroup.enter()
            FilterThumbnailGenerator.shared.generateThumbnail(image: previewCIImage, filter: filter) { [weak self] image in
                dispatchGroup.leave()
                guard let image else {
                    return
                }
                self?.filterThumbnails[filter.id] = image

            }
        }

        dispatchGroup.notify(queue: .main) {
            self.onPreviewImageUpdated?(self.previewImage)
        }
    }

    func thumbnail(for id: String) -> UIImage? {
        filterThumbnails[id]
    }
}
