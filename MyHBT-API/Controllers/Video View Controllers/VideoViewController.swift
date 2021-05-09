//
//  VideoViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 3/15/21.
//  Copyright © 2021 beta. All rights reserved.
//

import UIKit
import TwilioVideo

class VideoViewController: UIViewController, LocalParticipantDelegate {
    // Notification repository
    let notificationRepository = NotificationRepository()
    
    // Video and audio call repository
    let videoAndAudioCallRepository = VideoAndAudioCallRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    // Chat room name of chat room in which 2 users are in
    var chatRoomName = ""
    
    // User id of the call receiver
    var callReceiverUserId = ""
    
    // Create a CameraSource to provide content for the video track
    var localVideoTrack: LocalVideoTrack?
    
    // Create an audio track
    var localAudioTrack = LocalAudioTrack()
    
    // Camera source to get access to user local camera
    var camera: CameraSource?
    
    // Room object in which both users are in
    var room: Room?
    
    // Avatar of the call receiver
    @IBOutlet weak var callReceiverAvatar: UIImageView!
    
    // Name of the call receiver
    @IBOutlet weak var callReceiverName: UILabel!
    
    // Status of the call
    @IBOutlet weak var callStatus: UILabel!
    
    // Local video view
    @IBOutlet weak var videoView: UIView!
    
    // Remote video view
    @IBOutlet weak var remoteVideoView: UIView!
    
    // The end call button
    @IBAction func endCallButton(_ sender: UIButton) {
        // Call the function to end the video call
        endVideoCall()
    }
    
    // Remote video
    var remoteVideo: VideoView?
    
    // Local video
    var localVideo: VideoView?
    
    // Remote participant
    var remoteParticipant: RemoteParticipant?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize remote video view and local video view
        self.remoteVideo = VideoView(frame: self.remoteVideoView.bounds, delegate: self)
        self.localVideo = VideoView(frame: self.videoView.bounds, delegate: self)
        
        /*
         Initially,
         - Hide local video view
         - Show call receiver user avatar
         - Show call receiver name
         - Show call status
         */
        videoView.isHidden = true
        callReceiverName.isHidden = false
        callReceiverAvatar.isHidden = false
        callStatus.isHidden = false
        
        // Call the function to make the avatar look round
        AdditionalFunctions.init().makeRounded(image: callReceiverAvatar)
        
        // Call the function to get info of the call receiver
        getInfoOfCallReceiver(userId: callReceiverUserId)
        
        // Ask for user's permission to use the camera
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            // Call the function to start the video call
            startVideoCall()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                    // Call the function to start the video call
                    self.startVideoCall()
               } else {
                    // User rejected
               }
           })
        }
    }
    
    // The function to start the video call (when permission is granted)
    func startVideoCall() {
        // Start capturing local video
        self.startPreview()
        
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Call the function to get connected to the chat room
            self.connectToAChatRoom(roomName: self.chatRoomName, userId: userObject._id)
        }
    }
    
    // The function to end the video call
    func endVideoCall() {
        // Call the function to delete the room
        videoAndAudioCallRepository.deleteVideoChatRoom(chatRoomName: chatRoomName) { (isRemoved) in
            // If room is removed, dismiss the current video call view controller
            // Dismiss the current video call view controller
            if (isRemoved) {
                DispatchQueue.main.async {
                    //self.dismiss(animated: true, completion: nil)
                    //self.presentingViewController?.dismiss(animated: false, completion: nil)
                    self.performSegue(withIdentifier: "videoCallToMessageRoom", sender: self)
                }
            }
        }
    }
    
    // The function to connect to a chat room
    /*
     At this point, caller will initiate the call and call receiver will answer
     When caller calll this function, display the is calling signal
     When call receiver call this function, call is accepted and started
     */
    func connectToAChatRoom(roomName: String, userId: String) {
        // Call the function to get access token for the user to get into chat room with specified room name
        videoAndAudioCallRepository.getAccessTokenIntoVideoChatRoom(chatRoomName: roomName, userId: userId) { (accessToken) in
            // Call the function to create video chat room with specified room name
            self.videoAndAudioCallRepository.createVideoChatRoom(chatRoomName: roomName) { (isExisted) in
                if (isExisted) {
                    // Specify room name, video and audio via options
                    let connectOptions = ConnectOptions(token: accessToken) { (builder) in
                        // Room name
                        builder.roomName = roomName
                        
                        // Add video to the builder option
                        if let videoTrack = self.localVideoTrack {
                            builder.videoTracks = [ videoTrack ]
                        }
                    }
                    
                    // Join the chat room
                    self.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
                } else {
                    // Specify room name, video and audio via options
                    let connectOptions = ConnectOptions(token: accessToken) { (builder) in
                        // Room name
                        builder.roomName = roomName
                        
                        // Add video to the builder option
                        if let videoTrack = self.localVideoTrack {
                            builder.videoTracks = [ videoTrack ]
                        }
                    }
                    
                    // Join the chat room
                    self.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
                }
            }
        }
    }
    
    //************************************************ LOCAL VIDEO ************************************************
    // The function to set up and show camera of local user (for preview)
    func startPreview() {
        // Front camera source
        let frontCamera = CameraSource.captureDevice(position: .front)
        
        // Back camera source
        let backCamera = CameraSource.captureDevice(position: .back)

        // If both camera sources are available, start setting up camera options
        if (frontCamera != nil || backCamera != nil) {
            // Set up camera options
            let options = CameraSourceOptions { (builder) in
                if #available(iOS 13.0, *) {
                    // Track UIWindowScene events for the key window's scene.
                    // The example app disables multi-window support in the .plist (see UIApplicationSceneManifestKey).
                    DispatchQueue.main.async {
                        builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)
                    }
                }
            }
            
            // Preview our local camera track in the local video preview view.
            // Set up camera
            camera = CameraSource(options: options, delegate: self)
            
            // Update local video track
            localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")

            // Add renderer to video track for local track
            localVideoTrack!.addRenderer(self.localVideo!)
            
            // Add renderer to video view for local video
            self.videoView.addSubview(self.localVideo!)

            if (frontCamera != nil && backCamera != nil) {
                // We will flip camera on tap.
                DispatchQueue.main.async {
                    // Tap gesture to switch camera
                    let tap = UITapGestureRecognizer(target: self, action: #selector(VideoViewController.flipCamera))
                    
                    // Add tap gesture to local video view
                    self.videoView.addGestureRecognizer(tap)
                }
            }

            // Start camera capturing
            camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    // Show error
                    print(error)
                } else {
                    // Mirror the front camera
                    self.localVideo!.shouldMirror = (captureDevice.position == .front)
                }
            }
        }
        else {
        }
    }
    
    // The function to flip camera
    @objc func flipCamera() {
        // Capture device
        var newDevice: AVCaptureDevice?

        // Capture device should be camera of current device
        if let camera = self.camera, let captureDevice = camera.device {
            // If current camera is front, switch it to back
            if captureDevice.position == .front {
                newDevice = CameraSource.captureDevice(position: .back)
            } // Otherwise, switch it to front
            else {
                newDevice = CameraSource.captureDevice(position: .front)
            }

            // Set up new camera configuration
            if let newDevice = newDevice {
                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
                    if let error = error {
                        // Show error
                        print(error)
                    } else {
                        // Front camera should be mirror
                        self.localVideo!.shouldMirror = (captureDevice.position == .front)
                    }
                }
            }
        }
    }
    //************************************************ END LOCAL VIDEO ************************************************
    
    // The function to set up remote participant
    func renderRemoteParticipant(participant : RemoteParticipant) -> Bool {
        // This example renders the first subscribed RemoteVideoTrack from the RemoteParticipant.
        let videoPublications = participant.remoteVideoTracks
        
        /*
        if let subscribedVideoTrack = videoPublications[0].videoTrack {
            setupRemoteVideoView()
            subscribedVideoTrack.addRenderer(self.remoteVideo!)
            self.remoteParticipant = participant
            return true
        }
         */
    
        for publication in videoPublications {
            if let subscribedVideoTrack = publication.remoteTrack, publication.isTrackSubscribed {
                setupRemoteVideoView()
                subscribedVideoTrack.addRenderer(self.remoteVideo!)
                self.remoteParticipant = participant
                return true
            }
        }
        
        return false
    }
    
    // The function to set up remote video view
    func setupRemoteVideoView() {
        print("Add subview")
        
        self.remoteVideoView.addSubview(self.remoteVideo!)
        
        // `VideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
        // scaleAspectFit is the default mode when you create `VideoView` programmatically.
        self.remoteVideo!.contentMode = .scaleAspectFill;

        let centerX = NSLayoutConstraint(item: self.remoteVideo!,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: self.remoteVideo!,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerY)
        let width = NSLayoutConstraint(item: self.remoteVideo!,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: self.view,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       multiplier: 1,
                                       constant: 0);
        self.view.addConstraint(width)
        let height = NSLayoutConstraint(item: self.remoteVideo!,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: self.view,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        multiplier: 1,
                                        constant: 0);
        self.view.addConstraint(height)
    }
    
    // The function to clean up remote participant
    func cleanupRemoteParticipant() {
        if self.remoteParticipant != nil {
            // Remove remote video view from super view (container)
            self.remoteVideo?.removeFromSuperview()
            
            // Set remote video back to nil
            self.remoteVideo = nil
            
            // Set remote participant back to nil
            self.remoteParticipant = nil
        }
    }
    
    // The function to load info of thec call receiver
    func getInfoOfCallReceiver(userId: String) {
        // Call the function to get info of user based on user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            DispatchQueue.main.async {
                // Load user name into the label
                self.callReceiverName.text = userObject.fullName
                
                // Load user avatar into the image view
                self.callReceiverAvatar.sd_setImage(with: URL(string: userObject.avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
            }
        }
    }
}

extension VideoViewController : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        //logMessage(messageText: "Camera source failed with error: \(error.localizedDescription)")
    }
}

extension VideoViewController : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

extension VideoViewController : RoomDelegate {
    // When user get connected to a room
    // user of this device can be either a user to initiate a call or a user to receive the call
    func roomDidConnect(room: Room) {
        // Get number of users that are currently inside the room
        let currentNumberOfUsersInsideRoom = room.remoteParticipants.count
        
        // If there is no one in the room, it means that user of this device is the caller
        // in that case, send notification to the call receiver and let the call receiver know that there is an incoming video call
        // Title will be "video-chat-received" ("title" for now)
        // body will be chat room id in which 2 users will be in if call is accepted as well as user id of the currently logged in user
        if (currentNumberOfUsersInsideRoom == 0) {
            // Get user id of the currently logged in user
            userRepository.getInfoOfCurrentUser { (userObject) in
                // Send notification to the call receiver
                self.notificationRepository.sendNotificationToUser(userId: self.callReceiverUserId, notificationContent: "\(self.chatRoomName)-\(userObject._id)", notificationTitle: "incoming-video-call") {
                    DispatchQueue.main.async {
                        // Show the ringing signal
                        // Change call status from "Connecting..." to "Ringing..."
                        self.callStatus.text = "Ringing..."
                    }
                }
            }
        } // Otherwise, user of this device is call receiver. If that is the case, start the call
        else {
            // Start the call
            // Show local video view
            self.videoView.isHidden = false
            
            // Hide the call status
            self.callStatus.isHidden = true
            
            // Hide call receiver name
            self.callReceiverName.isHidden = true
            
            // Hide the call receiver avatar
            self.callReceiverAvatar.isHidden = true
        }
        
        // Get info of local user
        if let localParticipant = room.localParticipant {
            print("Local identity \(localParticipant.identity)")

            // Set the delegate of the local particiant to receive callbacks
            localParticipant.delegate = self
        }
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        print("Disconnected from room \(room.name), error = \(String(describing: error))")
        
        self.cleanupRemoteParticipant()
        self.room = nil
        
        // Dismiss the current video call view controller
        self.navigationController?.popViewController(animated: true)
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        print("Failed to connect")
    }
    
    func roomIsReconnecting(room: Room, error: Error) {
        print("Reconnecting to room \(room.name), error = \(String(describing: error))")
    }

    func roomDidReconnect(room: Room) {
        print("Reconnected to room \(room.name)")
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        print ("Participant \(participant.identity) has joined Room \(room.name)")
        
        // Start the call
        // Show local video view
        self.videoView.isHidden = false
        
        // Hide the call status
        self.callStatus.isHidden = true
        
        // Hide call receiver name
        self.callReceiverName.isHidden = true
        
        // Hide the call receiver avatar
        self.callReceiverAvatar.isHidden = true
        
        // Set the delegate of the remote participant to receive callbacks
        participant.delegate = self
    }
    
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

extension VideoViewController : RemoteParticipantDelegate {
    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has offered to share the video Track.
    }

    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has stopped sharing the video Track.
    }

    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has offered to share the audio Track.
    }

    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has stopped sharing the audio Track.
    }
    
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        /*
        // The LocalParticipant is subscribed to the RemoteParticipant's video Track. Frames will begin to arrive now.
        print("Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")
        
        // Get info from the remote view
        if let remoteView = VideoView.init(frame: self.remoteVideoView.bounds,
                                           delegate:self) {
            
            
            // Add remote view to remote video track
            videoTrack.addRenderer(remoteView)
            
            //
            self.remoteVideoView.addSubview(remoteView)
        }
         */
        
        if (self.remoteParticipant == nil) {
            _ = renderRemoteParticipant(participant: participant)
        }
    }
    
    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        if self.remoteParticipant == participant {
            cleanupRemoteParticipant()
        }
    }
    
    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
        
    }

    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        print("Participant \(participant.identity) enabled \(publication.trackName) video track")
    }

    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        print("Participant \(participant.identity) disabled \(publication.trackName) video track")
    }

    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        print("Participant \(participant.identity) enabled \(publication.trackName) audio track")
    }

    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        print("Participant \(participant.identity) disabled \(publication.trackName) audio track")
    }

    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
        print("FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }

    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        print("FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}

// MARK:- VideoViewDelegate
extension ViewController : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK:- CameraSourceDelegate
extension ViewController : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        // Show error
        print(error)
    }
}
