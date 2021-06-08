//
//  ViewController.swift
//  ShazamKit
//
//  Created by Sai Kambampati on 6/8/21.
//

import UIKit
import ShazamKit

class ViewController: UIViewController, SHSessionDelegate {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var albumImage: UIImageView!

    private let audioEngine = AVAudioEngine()
    private let session = SHSession()
    private let signatureGenerator = SHSignatureGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoLabel.text = ""
        session.delegate = self
    }
    
    @IBAction func shazam() {
        let audioSession = AVAudioSession.sharedInstance()

        audioSession.requestRecordPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    self.titleLabel.text = "Preparing"
                }
                
                try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                let inputNode = self.audioEngine.inputNode
                let recordingFormat = inputNode.outputFormat(forBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                    try! self.signatureGenerator.append(buffer, at: nil)
                    self.session.matchStreamingBuffer(buffer, at: nil)
                }

                self.audioEngine.prepare()
                try! self.audioEngine.start()
                DispatchQueue.main.async {
                    self.titleLabel.text = "Listening"
                }
            } else {
                DispatchQueue.main.async {
                    self.titleLabel.text = "Please Enable Permissions"
                }
            }
        }
        
        
    }
    
    public func session(_ session: SHSession, didFind match: SHMatch) {
        guard let matchedMediaItem = match.mediaItems.first else {
            return
        }
        
        DispatchQueue.main.async {
            self.titleLabel.text = matchedMediaItem.title
            if let artist = matchedMediaItem.artist {
                self.infoLabel.text = "This song is by \(artist)"
            }
            self.albumImage.image = UIImage(data: try! Data(contentsOf: matchedMediaItem.artworkURL!))
        }
        
    }
}

