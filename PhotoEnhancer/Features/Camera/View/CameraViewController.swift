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

    private var recordingTimer: Timer?
    private var recordingSeconds = 0
    private var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    deinit {

    }

    private func setupUI() {

        self.title = "Camera"
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

    @IBAction func capturePhoto(_ sender: UIButton) {
        captureManager.capturePhoto { image in
            guard let image else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("Photo Saved")
        }
    }
    

  private func toggleRecording() {
        //
        //        isRecording.toggle()
        //
        //        if isRecording {
        //
        //            recordButton.setTitle("STOP", for: .normal)
        //            captureManager.startRecording()
        //
        //        } else {
        //
        //            recordButton.setTitle("REC", for: .normal)
        //            captureManager.stopRecording()
        //        }
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
}


// MARK: Capture Delegate
extension CameraViewController: CaptureManagerDelegate {

    func captureManager(_ manager: CaptureManager, didOutput image: CIImage) {
        previewView.render(image: image)
    }
}


//MARK: Features
extension CameraViewController {

    @objc
    private func handleFocusTap(_ gesture: UITapGestureRecognizer) {

        let point = gesture.location(in: previewView)
        let normalized = CGPoint(x: point.y / previewView.bounds.height, y: 1 - (point.x / previewView.bounds.width))
        captureManager.focus(at: normalized)
        showFocusRing(at: point)
    }

    private func showFocusRing(at point: CGPoint) {
//
//        focusRingView.center = point
//
//        focusRingView.transform =
//        CGAffineTransform(scaleX: 1.5, y: 1.5)
//
//        focusRingView.alpha = 1
//
//        UIView.animate(
//            withDuration: 0.25
//        ) {
//
//            self.focusRingView.transform = .identity
//
//        } completion: { _ in
//
//            UIView.animate(
//                withDuration: 0.25,
//                delay: 0.5
//            ) {
//
//                self.focusRingView.alpha = 0
//            }
//        }
    }

    @objc
    private func switchCamera() {

        UIView.transition(with: previewView, duration: 0.35, options: .transitionFlipFromLeft) {
        } completion: { _ in
        }

        captureManager.switchCamera()
    }

    private func startRecordingTimer() {

//        recordingSeconds = 0
//
//        durationLabel.text = "00:00"
//
//        recordingTimer?.invalidate()
//
//        recordingTimer = Timer.scheduledTimer(
//            withTimeInterval: 1,
//            repeats: true
//        ) { [weak self] _ in
//
//            guard let self else { return }
//
//            self.recordingSeconds += 1
//
//            let minutes =
//            self.recordingSeconds / 60
//
//            let seconds =
//            self.recordingSeconds % 60
//
//            self.durationLabel.text =
//            String(
//                format: "%02d:%02d",
//                minutes,
//                seconds
//            )
//        }
    }

    private func stopRecordingTimer() {

        recordingTimer?.invalidate()

        recordingTimer = nil
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
