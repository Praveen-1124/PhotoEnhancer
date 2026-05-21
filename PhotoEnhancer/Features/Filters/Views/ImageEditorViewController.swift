//
//  ImageEditorViewController.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 08/05/26.
//

import UIKit

class ImageEditorViewController: UIViewController {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var filterTitleLabel: UILabel!

    private let viewModel = ImageEditorViewModel()
    var originalImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    deinit {
        print("\(Self.self): Deinited")
    }

    private func setupUI() {

        self.title = "Filters"
        sliderView.alpha = 0
        setupCollectionView()
        viewModel.setOriginalImage(image: originalImage)
    }

    private func setupCollectionView() {

        collectionView.register([AdjustmentCell.self, FilterCell.self])
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }

    private func bindViewModel() {

        viewModel.onPreviewImageUpdated = { [weak self] image in
            guard let self else { return }
            DispatchQueue.main.async {
                self.previewImage.image = image
                self.collectionView.reloadData()
            }
        }
    }


    @IBAction func didClickEditMode(_ sender: UISegmentedControl) {

        let mode: EditingMode = sender.selectedSegmentIndex == 0 ? .Filter : .Adjustment
        viewModel.currentMode = mode
        collectionView.reloadData()

        switch mode {
        case .Filter:
            guard let filter = viewModel.selectedFilter else {
                sliderView.alpha = 0
                return
            }
            updateFilter(filter: filter)
        case .Adjustment:
            guard let adjustment = viewModel.selectedAdjustment else {
                sliderView.alpha = 1
                return
            }
            updateAdjustment(adjustment: adjustment)
        }
    }

    @IBAction func didChangeSliderValue(_ sender: UISlider) {

        let value = sender.value
        if viewModel.currentMode == .Filter {
            viewModel.updateFilterIntensity(value)
        } else {
            guard let stepValue = viewModel.selectedAdjustment?.stepValue else { return }
            let snappedValue = round(value / stepValue ) * stepValue
            sender.value = snappedValue
            viewModel.updateAdjustment(value: snappedValue)
        }
    }
}

extension ImageEditorViewController {

    private func updateFilter(filter: ImageFilterable) {

        let range = filter.intensityRange
        configureSlider(isHidden: !filter.supportsIntensity,
                        min: range.lowerBound,
                        max: range.upperBound,
                        value: viewModel.currentFilterIntensity(for: filter))
        filterTitleLabel.text = filter.title.uppercased()
    }

    private func updateAdjustment(adjustment: ImageAdjustable) {

        let range = adjustment.sliderRange
        configureSlider(isHidden: false,
                        min: range.lowerBound,
                        max: range.upperBound,
                        value: viewModel.currentAdjustmentIntensity(for: adjustment))
        filterTitleLabel.text = adjustment.title.uppercased()
    }

    private func configureSlider(isHidden: Bool, min: Float, max: Float, value: Float ) {

        sliderView.alpha = isHidden ? 0 : 1

        guard !isHidden else { return }
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
    }

}

extension ImageEditorViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.currentMode == .Filter {
            return viewModel.filters.count
        }
        return viewModel.adjustments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if viewModel.currentMode == .Filter {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.rid, for: indexPath) as! FilterCell
            let filter = viewModel.filters[indexPath.item]
            cell.configure(title: filter.title,
                           image: viewModel.thumbnail(for: filter.id),
                           isSelected: viewModel.isSelected(filter))
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdjustmentCell.rid, for: indexPath) as! AdjustmentCell
            let adjustment = viewModel.adjustments[indexPath.row]
            cell.configure(title: adjustment.title,
                           icon: adjustment.icon,
                           isSelected: viewModel.isSelected(adjustment))
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch viewModel.currentMode {
        case .Filter:
            let filter = viewModel.filters[indexPath.item]
            viewModel.selectFilter(filter)
            updateFilter(filter: filter)

        case .Adjustment:
            let adjustment = viewModel.adjustments[indexPath.row]
            viewModel.selectAdjustment(adjustment)
            updateAdjustment(adjustment: adjustment)
        }

        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 80)
    }
}

