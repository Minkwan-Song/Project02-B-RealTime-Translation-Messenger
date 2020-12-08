//
//  MessageBox.swift
//  PapagoTalk
//
//  Created by 송민관 on 2020/11/26.
//

import Foundation

final class MessageBox {
    
    var currentUserID: Int
    var messages = [Message]()
    
    init(userID: Int) {
        currentUserID = userID
    }
    
    func append(_ messages: [Message]) {
        messages.forEach { append($0) }
    }
    
    func append(_ message: Message) {
        var message = message
        message = setType(of: message)
        
        guard let lastMessage = messages.last else {
            messages.append(message)
            return
        }
        message = setMessageIsFirst(of: message, comparedBy: lastMessage)
        message = setShouldImageShow(of: message, comparedBy: lastMessage)
        setShouldTimeShow(of: message, comparedBy: lastMessage)
    }
    
    func setMessageIsFirst(of newMessage: Message, comparedBy lastMessage: Message) -> Message {
        let isNotFirstOfDay = Calendar.isSameDate(of: newMessage.timeStamp, with: lastMessage.timeStamp)
        var message = newMessage
        message.setIsFirst(with: !isNotFirstOfDay)
        return message
    }
    
    func setType(of newMessage: Message) -> Message {
        var message = newMessage
        message.setType(by: currentUserID)
        return message
    }
    
    private func setShouldImageShow(of newMessage: Message, comparedBy lastMessage: Message) -> Message {
        guard newMessage.type == .received,
              lastMessage.type == .received,
              newMessage.sender.id == lastMessage.sender.id,
              DateFormatter.chatTimeFormat(of: newMessage.timeStamp) == DateFormatter.chatTimeFormat(of: lastMessage.timeStamp) else {
            return newMessage
        }
        var message = newMessage
        message.shouldImageShow = false
        return message
    }
    
    private func setShouldTimeShow(of newMessage: Message, comparedBy lastMessage: Message) {
        guard newMessage.sender.id == lastMessage.sender.id,
              DateFormatter.chatTimeFormat(of: newMessage.timeStamp) == DateFormatter.chatTimeFormat(of: lastMessage.timeStamp) else {
            messages.append(newMessage)
            return
        }
        var lastMessage = lastMessage
        lastMessage.shouldTimeShow = false
        messages.removeLast()
        messages.append(contentsOf: [lastMessage, newMessage])
    }
}