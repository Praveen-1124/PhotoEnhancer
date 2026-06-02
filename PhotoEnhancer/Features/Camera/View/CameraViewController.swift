//
//  CameraViewController.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 13/05/26.
//

import UIKit
import AVFoundation
import Photos

final class CameraViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previewView: CameraPreviewView!

    private let captureManager = CaptureManager()
    private var selectedFilter: CameraFilter = .original
    private var thumbnailImages: [CameraFilter: UIImage] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    deinit {
        print("\(Self.self): Deinited")
    }

    private func setupUI() {

//        self.title = "Camera"
        checkPermissions()
        setupCollectionView()
        captureManager.delegate = self
        captureManager.filters = selectedFilter.makeFilters()
    }

    private func setupCollectionView() {

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register([CameraFilterCell.self])
    }

    private func checkPermissions() {

        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else { return }
            AVCaptureDevice.requestAccess(for: .audio) { _ in
                DispatchQueue.main.async {
                    self.captureManager.configure()
                }
            }
        }
    }

    @IBAction func capturePhoto(_ sender: UIButton) {
        captureManager.capturePhoto { image in
            guard let image else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}


// MARK: Capture Delegate
extension CameraViewController: CaptureManagerDelegate {

    func captureManager(_ manager: CaptureManager, didOutput image: CIImage) {
        previewView.render(image: image)
    }
}


// MARK: CollectionView Delegate
extension CameraViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        CameraFilter.allCases.count
    }

    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraFilterCell.rid, for: indexPath) as! CameraFilterCell
        let filter = CameraFilter.allCases[indexPath.item]
        cell.configure(with: filter, isSelected: filter == selectedFilter)
        return cell
    }

    func collectionView( _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectedFilter = CameraFilter.allCases[indexPath.item]
        captureManager.filters =
        selectedFilter.makeFilters()
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 100, height: 44)
    }
}
