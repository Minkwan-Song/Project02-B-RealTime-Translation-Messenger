//
//  SpeechRegcognizerButton.swift
//  PapagoTalk
//
//  Created by Byoung-Hwi Yoon on 2020/12/02.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class MicrophoneButton: UIButton {
    
    enum ContentsMode {
        case big
        case midium
        case small
        case none
        
        var size: CGFloat {
            switch self {
            case .big:
                return 70
            case .midium:
                return 70
            case .small:
                return 50
            case .none:
                return 0
            }
        }
    }
    
    var buttonColor: UIColor?
    private var latestCenter: CGPoint?
    private let disposeBag = DisposeBag()
    
    var mode: ContentsMode = .small {
        didSet {
            let newSize = CGSize(width: mode.size, height: mode.size)
            frame.size = newSize
            bounds.size = newSize
            updateShadow()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureShadow()
        commonInit()
        attachGesture()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureShadow()
        commonInit()
        attachGesture()
    }
    
    init(mode: ContentsMode, origin: CGPoint) {
        let size = CGSize(width: mode.size, height: mode.size)
        let rect = CGRect(origin: origin, size: size)
        super.init(frame: rect)
        self.mode = mode
        configureShadow()
        commonInit()
        attachGesture()
    }
 
    override func draw(_ rect: CGRect) {
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let offset = rect.width * 0.5 / 2
        
        let circlePath = UIBezierPath(ovalIn: rect)
        (buttonColor ?? UIColor.systemGreen).set()
        circlePath.fill()
        
        let plusPath = UIBezierPath()
        plusPath.move(to: CGPoint(x: center.x - offset, y: center.y))
        plusPath.addLine(to: CGPoint(x: center.x + offset, y: center.y))
        
        plusPath.move(to: CGPoint(x: center.x, y: center.y - offset))
        plusPath.addLine(to: CGPoint(x: center.x, y: center.y + offset))
        plusPath.close()
    }
    
    func moveForSpeech(completion: (() -> Void)?) {
        guard let superviewCenter = superview?.center else { return }
        latestCenter = center
        let newY = superviewCenter.y + Constant.speechViewHeight/2 - Constant.speechViewBottomInset  - (frame.height/2)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.center = CGPoint(x: superviewCenter.x, y: newY)
        }
        completion: { _ in
            completion?()
        }
    }
    
    func moveToLatest() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.center = self?.latestCenter ?? .zero
        }
    }
    
    private func configureShadow() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        layer.shadowOffset = CGSize(width: 2, height: 8)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2.0
        layer.masksToBounds = false
        
        updateShadow()
    }
    
    private func updateShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width).cgPath
    }
    
    private func commonInit() {
        let image = UIImage(systemName: "mic",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: mode.size/2,
                                                                           weight: .semibold))
        setImage(image, for: .normal)
        tintColor = .white
        contentMode = .center
        imageView?.contentMode = .scaleAspectFit
    }
    
    private func attachGesture() {
        rx.panGesture()
              .asDriver()
              .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let translation = $0.translation(in: self)
                self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
                $0.setTranslation(.zero, in: self)
                
                if $0.state == .ended {
                    self.moveButtonToSide()
                }
              })
              .disposed(by: disposeBag)
    }
    
    private func moveButtonToSide() {
        guard let superViewWidth = superview?.bounds.width else {
            return
        }
        let isLeft = center.x < superViewWidth/2
        let nexX = isLeft ? 12 + bounds.width/2 : superViewWidth - 12 - bounds.width/2
        let movedY = center.y
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.center = CGPoint(x: nexX, y: movedY)
        }
        
    }
}