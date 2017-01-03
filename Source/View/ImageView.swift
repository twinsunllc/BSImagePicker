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

class ImageView: UIView {
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }

    override var contentMode: UIViewContentMode {
        didSet { layoutImageView() }
    }

    private let imageView: UIImageView

    init(image: UIImage?) {
        imageView = UIImageView(image: image)
        super.init(frame: .zero)
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView(image: nil)
        super.init(coder: aDecoder)
        addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutImageView()
    }

    private func layoutImageView() {
        guard let image = image else { return }
        contentMode.layout(image: image, in: imageView, bounds: bounds)
    }
}

extension UIViewContentMode {
    typealias Ratio = (width: CGFloat, height: CGFloat)

    fileprivate func layout(image: UIImage, in imageView: UIImageView, bounds: CGRect) {
        switch self {
        case .scaleAspectFill:
            let ratio = calculateRatio(image: image, bounds: bounds)
            let size = calculateSize(image: image, with: ratio, using: min)
            updateBounds(imageView: imageView, size: size)
            imageView.center = bounds.center
        case .scaleAspectFit:
            let ratio = calculateRatio(image: image, bounds: bounds)
            let size = calculateSize(image: image, with: ratio, using: max)
            updateBounds(imageView: imageView, size: size)
            imageView.center = bounds.center
        default: break
        }
    }

    private func calculateRatio(image: UIImage, bounds: CGRect) -> Ratio {
        let width = image.size.width / bounds.size.width
        let height = image.size.height / bounds.size.height

        return (width: width, height: height)
    }

    private func calculateSize(image: UIImage, with ratio: Ratio, using minMax: (CGFloat, CGFloat) -> CGFloat) -> CGSize {
        return CGSize(width: image.size.width / minMax(ratio.width, ratio.height), height: image.size.height / minMax(ratio.width, ratio.height))
    }

    private func updateBounds(imageView: UIImageView, size: CGSize) {
        imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}

extension CGRect {
    fileprivate var center: CGPoint {
        return CGPoint(x: size.width / 2, y: size.height / 2)
    }
}
