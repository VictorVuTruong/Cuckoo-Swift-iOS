//
//  MessageRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 2/28/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class MessageRepository {
    // The decoder which will be used to decode the JSON array
    let decoder = JSONDecoder()
    
    // User repository
    let userRepository = UserRepository()
    
    // The object to perform API operations
    let apiOperations = APIOperations()
    
    // The function to get chat room id between the 2 users
    func getChatRoomBetween2Users(userId: String, completion: @escaping (MessageRoom) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET request
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/messageRoom/getMessageRoomIdBetween2Users?user1=\(userObject._id)&user2=\(userId)") { (responseData) in
                    // Get status of the call
                    let status = responseData["status"] as! String
                    
                    do {
                        // If the status is "success", it means that there is chat room between the 2 users, go ahead and get the chat room id and
                        // pass it to the next activity
                        if (status == "success") {
                            // Get data from the response (this will include the chat room id)
                            let data = responseData["data"] as! [String: Any]
                            
                            // Convert the chat room object from database into JSON data
                            let chatRoomJSONData = try JSONSerialization.data(withJSONObject: data, options: [])
                            
                            // Convert the JSON data into chat room object
                            let chatRoomObject = try self.decoder.decode(MessageRoom.self, from: chatRoomJSONData)
                            
                            // Return chat room id via callback function
                            completion(chatRoomObject)
                        } // Otherwise, there is no chat room between the 2 users, pass an empty string as chat room id to the next view controller
                        else {
                            // Return an empty string as chat room via callback function
                            completion(MessageRoom(_id: "", user1: "", user2: ""))
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // The function to get chat rooms in which currently logged in user are in
    func getChatRoomsOfCurrentUser(completion: @escaping ([MessageRoom]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET operation
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/messageRoom/getMessageRoomOfUser?userId=\(userObject._id)") { (responseData) in
                    do {
                        // Get the data
                        let dataFetched = responseData["data"] as! [[String: Any]]
                        
                        // Convert list of chat rooms from database into JSON data
                        let arrayOfChatRooms = try JSONSerialization.data(withJSONObject: dataFetched, options: [])
                        
                        // Convert the JSON data into array of notifications
                        let arrayOfChatRoomObjects = try self.decoder.decode([MessageRoom].self, from: arrayOfChatRooms)
                        
                        // Return array of chat room objects via callback function
                        completion(arrayOfChatRoomObjects)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // The function to get latest message of the chat room
    func getLatestMessageOfChatRoom(chatRoomId: String, completion: @escaping (Message) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/message/getLatestMessageOfMessageRoom?chatRoomId=\(chatRoomId)") { (responseData) in
            do {
                // Get the data (latest message)
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Convert message object from database into JSON data
                let latestMessage = try JSONSerialization.data(withJSONObject: dataFetched, options: [])
                
                // Convert the JSON data into message object
                let messageObject = try self.decoder.decode(Message.self, from: latestMessage)
                
                // Return latest message via callback function
                completion(messageObject)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to load all messages of the specified message room
    func loadAllMessagesOfRoom(chatRoomId: String, completion: @escaping ([Message]) -> ()) {
        // Call the function to perform GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/message?chatRoomId=\(chatRoomId)") { (responseData) in
            do {
                // Get the data (this contains array of messages)
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Get array of messages from the data
                let arrayOfMessages = dataFetched["documents"] as! [[String: Any]]
                
                // Convert array of messages from database into JSON data
                let arrayOfMessagesJSONData = try JSONSerialization.data(withJSONObject: arrayOfMessages, options: [])
                
                // Convert the JSON data into message object
                let arrayOfMessageObjects = try self.decoder.decode([Message].self, from: arrayOfMessagesJSONData)
                
                // Return array of messages via callback function
                completion(arrayOfMessageObjects)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to create new message sent by the current user
    func createNewMessage(messageContent: String, messageReceiver: String, completion: @escaping (String, String) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET request
                self.apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/message", body: [
                    "content" : messageContent,
                    "receiver" : messageReceiver,
                    "sender": userObject._id
                ]) { (responseData) in
                    // Get the data
                    let dataFetched = responseData["data"] as! [String: Any]
                    
                    // Get message id of the newly created message in the database
                    let newMessaegId = dataFetched["_id"] as! String
                    
                    // Get chat room id of chat room to which this message is sent
                    let chatRoomId = dataFetched["chatRoomId"] as! String
                    
                    // Return new message id and chat room via callback function
                    completion(newMessaegId, chatRoomId)
                }
            }
        }
    }
    
    // The function to create new message photo
    func createNewMessagePhoto(messageId: String, imageURL: String, completion: @escaping (Bool) -> ()) {
        // Call the function to perform POST operation
        apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/messagePhoto", body: [
            "messageId" : messageId,
            "imageURL" : imageURL
        ]) { (responseData) in
            // If response data is available, let the view controller know via callback function
            completion(true)
        }
    }
}
