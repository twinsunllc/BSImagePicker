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

class PreviewAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var source: UIImageView?
    var destination: UIImageView?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 5
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        guard let from = context.view(forKey: UITransitionContextViewKey.from), let to = context.view(forKey: UITransitionContextViewKey.to), let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to), let snapshot = to.snapshotView(afterScreenUpdates: true) else { return }
        let final = context.finalFrame(for: toVC)
        snapshot.frame = final
        let v = UIImageView()

        containerView.addSubview(to)
        containerView.addSubview(snapshot)

        to.isHidden = true

        UIView.animate(withDuration: transitionDuration(using: context), animations: { 
            snapshot.frame = final
        }) { (completed) in
            to.isHidden = false
            snapshot.removeFromSuperview()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
}
