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
    // Access token to get into video chat room
    // This will be issued by the server
    let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTSzFlZDBjNTJkZjllNTZkNjdkNWJlNTE4ODVhN2UwNzY5LTE2MTYwMjQ1NDYiLCJncmFudHMiOnsiaWRlbnRpdHkiOiJ2bnRydW9uZyIsInZpZGVvIjp7fX0sImlhdCI6MTYxNjAyNDU0NiwiZXhwIjoxNjE2MDI4MTQ2LCJpc3MiOiJTSzFlZDBjNTJkZjllNTZkNjdkNWJlNTE4ODVhN2UwNzY5Iiwic3ViIjoiQUNhZjVjN2MwMzliMjE0OTk0YTAzMGRmODdmMGY3M2QyNiJ9.gaNw6EmPO0fIGSGYztZvjFHq4_OIClgIMaKX-Q9lzUE"
    
    // Create a CameraSource to provide content for the video track
    var localVideoTrack: LocalVideoTrack?
    
    // Create an audio track
    var localAudioTrack = LocalAudioTrack()
    
    // Camera source to get access to user local camera
    var camera: CameraSource?
    
    // Room object in which both users are in
    var room: Room?
    
    // The create room button
    @IBAction func createRoomButton(_ sender: Any) {
        // Specify room name, video and audio via options
        let connectOptions = ConnectOptions(token: accessToken) { (builder) in
            // Room name
            builder.roomName = "chat-room"
            
            // Add video to the builder option
            if let videoTrack = self.localVideoTrack {
                builder.videoTracks = [ videoTrack ]
            }
        }
        
        // Join the chat room
        room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
    }
    
    // The disconnect room button
    @IBAction func disconnectRoomButton(_ sender: UIButton) {
        // Call the function to disconnect with room
        room?.disconnect()
    }
    
    // Local video view
    @IBOutlet weak var videoView: UIView!
    
    // Remote video view
    @IBOutlet weak var remoteVideoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for user's permission to use the camera
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            // Already Authorized
            self.setUpCaptureSession()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
               if granted == true {
                    // User granted
                    self.setUpCaptureSession()
               } else {
                   // User rejected
               }
           })
        }
    }
    
    // The function to set up local camera and show it to local user
    func setUpCaptureSession () {
        // Create a video track with the capturer.
        if let camera = CameraSource(delegate: self) {
            // Create video track from local camera
            let videoTrack = LocalVideoTrack(source: camera)!
            
            // Update local video track
            self.localVideoTrack = videoTrack
            
            // VideoView is a VideoRenderer and can be added to any VideoTrack.
            let renderer = VideoView(frame: self.videoView.bounds, delegate: self)
            
            // Add renderer to the video track
            self.localVideoTrack!.addRenderer(renderer!)
            
            // Add renderer to local video view
            self.videoView.addSubview(renderer!)
            
            // Start the camera
            camera.startCapture(device: (CameraSource.captureDevice(position: .back))!)
        } else {
            print("Couldn't create CameraCapturer or LocalVideoTrack")
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
    func roomDidConnect(room: Room) {
        print("Did connect to Room")
        
        // Get info of local user
        if let localParticipant = room.localParticipant {
            print("Local identity \(localParticipant.identity)")

            // Set the delegate of the local particiant to receive callbacks
            localParticipant.delegate = self
        }
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        print("Failed to connect")
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        print ("Participant \(participant.identity) has joined Room \(room.name)")
        
        // Set the delegate of the remote participant to receive callbacks
        participant.delegate = self
    }
}

extension VideoViewController : RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
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
    }
}
