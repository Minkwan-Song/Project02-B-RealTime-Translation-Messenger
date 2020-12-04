//
//  ChatDrawerViewReactor.swift
//  PapagoTalk
//
//  Created by 송민관 on 2020/11/30.
//

import Foundation
import ReactorKit

final class ChatDrawerViewReactor: Reactor {
    
    typealias UserList = [User]
    
    enum Action {
        case fetchUsers
        case chatRoomCodeButtonTapped
        case leaveChatRoomButtonTapped
    }
    
    enum Mutation {
        case setUsers(UserList)
        case copyRoomCode(String)
        case setNeedToast(Bool)
        case setLeaveChatRoom(Bool)
    }
    
    struct State {
        var users: UserList
        var roomCode: String?
        var needToast: Bool
        var leaveChatRoom: Bool
    }
    
    private let networkService: NetworkServiceProviding
    private let userData: UserDataProviding
    private let roomID: Int
    let initialState: State
    
    init(networkService: NetworkServiceProviding, userData: UserDataProviding, roomID: Int, roomCode: String) {
        self.networkService = networkService
        self.userData = userData
        self.roomID = roomID
        initialState = State(users: UserList(), roomCode: nil, needToast: false, leaveChatRoom: false)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchUsers:
            return requestGetUserList(by: roomID)
        case .chatRoomCodeButtonTapped:
            return .concat ([
                .just(Mutation.setNeedToast(true)),
                .just(Mutation.copyRoomCode("554305")),
                .just(Mutation.setNeedToast(false))
            ])
        case .leaveChatRoomButtonTapped:
            return .just(Mutation.setLeaveChatRoom(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .setUsers(let users):
            state.users = users
        case .copyRoomCode(let roomCode):
            state.roomCode = roomCode
        case .setNeedToast(let needToast):
            state.needToast = needToast
        case .setLeaveChatRoom(let leaveChatRoom):
            state.leaveChatRoom = leaveChatRoom
        }
        return state
    }
    
    private func requestGetUserList(by roomID: Int) -> Observable<Mutation> {
        return networkService.getUserList(of: roomID)
            .asObservable()
            .compactMap { $0.roomById?.users }
            .map { $0.map { User(id: $0.id,
                                 nickName: $0.nickname,
                                 image: $0.avatar,
                                 language: .codeToLanguage(of: $0.lang)) } }
            .map { Mutation.setUsers($0) }
    }
}