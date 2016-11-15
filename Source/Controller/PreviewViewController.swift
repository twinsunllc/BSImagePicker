// The MIT License (MIT)
//
// Copyright (c) 2016 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

class PreviewViewController: UIViewController {
    @IBOutlet var overviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var previewCollectionView: UICollectionView!
    @IBOutlet var overviewCollectionView: UICollectionView!
    @IBOutlet var overviewCollectionViewHeightConstraint: NSLayoutConstraint!

    var album: Album?

    fileprivate var fullscreen: Bool = false {
        didSet {
            if fullscreen == oldValue { return }
            toggleFullscreen()
        }
    }
    
    static func instantiateFromStoryboard() -> PreviewViewController {
        return UIStoryboard(name: "Preview", bundle: Bundle.imagePicker).instantiateInitialViewController() as! PreviewViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.addTarget(self, action: #selector(PreviewViewController.didTap(sender:)))
        previewCollectionView.addGestureRecognizer(tapRecognizer)

        let doubleTapRecognizer = UITapGestureRecognizer()
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.addTarget(self, action: #selector(PreviewViewController.didDoubleTap(sender:)))
        tapRecognizer.require(toFail: doubleTapRecognizer)
        previewCollectionView.addGestureRecognizer(doubleTapRecognizer)

        setup(collectionView: previewCollectionView)
        setup(collectionView: overviewCollectionView)

        previewCollectionView.register(nib: UINib(nibName: "PreviewCell", bundle: Bundle.imagePicker), for: PreviewCell.self)
        overviewCollectionView.register(nib: UINib(nibName: "PreviewCell", bundle: Bundle.imagePicker), for: PreviewCell.self)
    }

    func setup(collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override var prefersStatusBarHidden : Bool {
        return fullscreen
    }

    // MARK: UIGestureRecognizer actions
    func didTap(sender: UIGestureRecognizer) {
        fullscreen = !fullscreen
    }

    func didDoubleTap(sender: UIGestureRecognizer) {
        let location = sender.location(in: previewCollectionView)
        guard let indexPath = previewCollectionView.indexPathForItem(at: location) else { return }
        guard let cell = previewCollectionView.cellForItem(at: indexPath) as? PreviewCell else { return }

        let targetZoomScale: CGFloat
        if cell.scrollView.zoomScale == 1 { // If we are already zoomed in, double tap will zoom out
            targetZoomScale = 2
            fullscreen = true
        } else { // Otherwise zoom in
            targetZoomScale = 1
            fullscreen = false
        }

        // Calculate a rect to zoom to
        let targetZoomPoint = sender.location(in: cell.scrollView)
        var destinationRect = CGRect.zero
        destinationRect.size.width = cell.scrollView.frame.width / targetZoomScale
        destinationRect.size.height = cell.scrollView.frame.height / targetZoomScale
        destinationRect.origin.x = targetZoomPoint.x - (destinationRect.width * 0.5)
        destinationRect.origin.y = targetZoomPoint.y - (destinationRect.height * 0.5)

        // Zoom to rect
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .allowUserInteraction, animations: {
            cell.scrollView.zoom(to: destinationRect, animated: false)
        }, completion: nil)
    }

    // MARK: Helpers for toggling fullscreen
    func toggleFullscreen() {
        toggleOverview()

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.toggleNavigationBar()
            self?.toggleStatusBar()
            self?.toggleBackgroundColor()
        }
    }

    func toggleNavigationBar() {
        navigationController?.setNavigationBarHidden(fullscreen, animated: true)
    }

    func toggleStatusBar() {
        setNeedsStatusBarAppearanceUpdate()
    }

    func toggleBackgroundColor() {
        let aColor: UIColor

        if fullscreen {
            aColor = UIColor.black
        } else {
            aColor = UIColor.white
        }

        view.backgroundColor = aColor
    }

    func toggleOverview() {
        if fullscreen {
            overviewHeightConstraint.constant = 0
        } else {
            overviewHeightConstraint.constant = 48
        }
    }
}

extension PreviewViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let album = album else { return 0 }
        return album.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let album = album else { return UICollectionViewCell() }

        let cell = collectionView.dequeue(cell: PreviewCell.self, for: indexPath)

        let photo = album[indexPath.row]
        cell.preview(photo)

        return cell
    }
}

extension PreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == previewCollectionView {
            return collectionView.bounds.size
        } else {
            return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == previewCollectionView {
            return 0
        } else {
            return 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == previewCollectionView {
            return UIEdgeInsets.zero
        } else {
            return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        }
    }
}
