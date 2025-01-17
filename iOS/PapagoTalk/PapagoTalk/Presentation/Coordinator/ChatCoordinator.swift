//
//  ChatCoordinator.swift
//  PapagoTalk
//
//  Created by Byoung-Hwi Yoon on 2020/12/05.
//

import UIKit
import RxCocoa

final class ChatCoordinator: Coordinator {
    
    weak var parentCoordinator: MainCoordinating?
    
    var networkService: NetworkServiceProviding
    var userData: UserDataProviding
    var messageParser: MessageParseProviding
    var historyManager: HistoryServiceProviding
    var roomID: Int?
    var code: String?
    
    init(networkService: NetworkServiceProviding,
         userData: UserDataProviding,
         messageParser: MessageParseProviding,
         historyManager: HistoryServiceProviding) {
        
        self.networkService = networkService
        self.userData = userData
        self.messageParser = messageParser
        self.historyManager = historyManager
    }
    
    func start() {
        guard let roomID = roomID, let code = code else {
            return
        }
        let chatWebSocket = WebSocketService()
        let viewController = storyboard.instantiateViewController(
            identifier: ChatViewController.identifier,
            creator: { [unowned self] coder -> ChatViewController? in
                let reactor = ChatViewReactor(networkService: networkService,
                                              userData: userData,
                                              messageParser: messageParser,
                                              chatWebSocket: chatWebSocket,
                                              historyManager: historyManager,
                                              roomID: roomID,
                                              code: code)
                let observer = BehaviorRelay(value: userData.micButtonSize)
                return ChatViewController(coder: coder, reactor: reactor, micButtonObserver: observer)
            }
        )
        viewController.coordinator = self
        parentCoordinator?.push(viewController)
    }
}

extension ChatCoordinator: ChatCoordinating {
    func presentSpeech(from presentingViewController: UIViewController) {
        guard let roomID = roomID else {
            return
        }
        let speechManager = SpeechService(userData: userData)
        let speechViewController = storyboard.instantiateViewController(
            identifier: SpeechViewController.identifier,
            creator: { [unowned self] coder -> SpeechViewController? in
                let reactor = SpeechViewReactor(networkService: networkService,
                                                userData: userData,
                                                speechManager: speechManager,
                                                roomID: roomID)
                return SpeechViewController(coder: coder, reactor: reactor)
            }
        )
        presentingViewController.addChild(speechViewController)
        
        let frame = presentingViewController.view.frame
        let bottomInset = presentingViewController.view.safeAreaInsets.bottom
        let height = frame.height/2 - bottomInset
        
        speechViewController.view.frame = CGRect(x: (frame.width - Constant.speechViewWidth)/2,
                                                 y: frame.height/4,
                                                 width: Constant.speechViewWidth,
                                                 height: height)
        
        UIView.transition(with: presentingViewController.view, duration: 0.4, options: [.transitionCrossDissolve]) {
            presentingViewController.view.addSubview(speechViewController.view)
        }
    }
    
    func presentDrawer(from presentingViewController: UIViewController,
                       with stateObserver: BehaviorRelay<Bool>,
                       micButtonSizeObserver: BehaviorRelay<MicButtonSize>) {
        guard let roomID = roomID, let code = code else {
            return
        }
        
        let visualEffectView = UIVisualEffectView()
        
        visualEffectView.frame = presentingViewController.view.frame
        presentingViewController.view.addSubview(visualEffectView)
        
        let drawerViewController = storyboard.instantiateViewController(
            identifier: ChatDrawerViewController.identifier,
            creator: { [unowned self] coder -> ChatDrawerViewController? in
                let reactor = ChatDrawerViewReactor(networkService: networkService,
                                                    userData: userData,
                                                    roomID: roomID,
                                                    roomCode: code)
                return ChatDrawerViewController(coder: coder,
                                                reactor: reactor,
                                                visualEffectView: visualEffectView,
                                                stateObserver: stateObserver,
                                                buttonSizeObserver: micButtonSizeObserver)
            }
        )
        drawerViewController.completion = {
            (presentingViewController as? ChatViewController)?.chatDrawerButton.isEnabled = true
        }
        
        let frame = presentingViewController.view.frame
        let drawerWidth = frame.width * 0.75
        
        drawerViewController.view.frame = CGRect(x: frame.width, y: .zero, width: drawerWidth, height: frame.height)
        drawerViewController.view.clipsToBounds = true
        
        presentingViewController.addChild(drawerViewController)
        presentingViewController.view.addSubview(drawerViewController.view)
    }
    
    func pushSetting(micButtonSizeObserver: BehaviorRelay<MicButtonSize>) {
        parentCoordinator?.pushSetting(micButtonSizeObserver)
    }
}
