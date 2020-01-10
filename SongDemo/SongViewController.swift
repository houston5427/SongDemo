//
//  SongViewController.swift
//  SongDemo
//
//  Created by Glen Lin on 2020/1/4.
//  Copyright © 2020 Glen Lin. All rights reserved.
//

import UIKit
import AVFoundation

class SongViewController: UIViewController {
    var audioPlayer = AVPlayer()
    var playItem : AVPlayerItem?
    var gridentLayer = CAGradientLayer()
    var index = 0
    var playList:[Song] = []
    let songs = [Song(name: "HandClap"),Song(name: "Changed"),Song(name: "BestOfMe")]
    var isPlaying = false
    
    @IBOutlet weak var songLenght: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var imageLabel: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playList = songs
        findSongPath(index: index)
        viewBackGround()
        updatePlayerUI()
        time()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main){
            (_) in
            self.index += 1
            self.index %= self.playList.count
            self.audioPlayer.pause()
            self.findSongPath(index: self.index)
            self.audioPlayer.play()
            self.updatePlayerUI()
            self.time()
        }
        
       
        
        let duration : CMTime = playItem!.asset.duration
        let second : Float64 = CMTimeGetSeconds(duration)
        timeSlider!.minimumValue = 0
        timeSlider!.maximumValue = Float(second)
        timeSlider!.isContinuous = false
 
    }
    
    @IBAction func playSong(_ sender: UIButton) {
    
        if !isPlaying {
            playButton.setImage(UIImage(systemName: "pause.fill"), for:.normal)
            isPlaying = true
            audioPlayer.play()
        }else{
            
            playButton.setImage(UIImage(systemName: "play.fill"), for:.normal)
            audioPlayer.pause()
            isPlaying = false
        }
        
    }
    
    @IBAction func previousAndNextSong(_ sender: UIButton) {
        
        switch sender.restorationIdentifier {
        case "next":
            if index == playList.count - 1{
                isPlaying = false
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
            index += 1
            index %= playList.count
        case "previous":
            if audioPlayer.currentTime().seconds < 4{
                if index > 0{
                    index -= 1
                }else if index == 0{
                    index = playList.count-1
                }
            }
        default:
            break
        }
        audioPlayer.pause()
        findSongPath(index: index)
        time()
        updatePlayerUI()
        audioPlayer.play()
    }
    
    

    @IBAction func adjustmentVolume(_ sender: UISlider) {
        
        audioPlayer.volume = volumeSlider.value
        
    }
    
    @IBAction func playTime(_ sender: UISlider) {
        let seconds : Int64 = Int64(timeSlider.value)
        let targetTime :CMTime = CMTimeMake(value: seconds, timescale: 1)
        audioPlayer.seek(to: targetTime)
        if audioPlayer.rate == 0{
            audioPlayer.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    
    
    func time(){
           audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main){
               (CMTime) -> Void in
               if self.audioPlayer.currentItem?.status == .readyToPlay{
                   let currentTime = CMTimeGetSeconds(self.audioPlayer.currentTime())
                   self.timeSlider!.value = Float(currentTime)
                   let all : Int = Int(currentTime)
                   let m : Int = all % 60
                   let f : Int = Int(all/60)
                   var time : String = ""
                   
                   if f<10{
                       time = "0\(f):"
                   }else{
                       time = "\(f)"
                   }
                   if m<10 {
                       time += "0\(m)"
                   }else {
                       time += "\(m)"
                   }
                    self.timeLabel.text = time
                    
               }
           }
       }
    
    
    
    func findSongPath(index: Int) {
        let songName = playList[index].name
        let image = UIImage(named: songName)
        imageLabel.image = image
        let fileUrl = Bundle.main.url(forResource: songName, withExtension: "mp3")!
        playItem = AVPlayerItem(url: fileUrl)
        audioPlayer.replaceCurrentItem(with: playItem)
    }
    
    func viewBackGround(){
        gridentLayer.frame = view.bounds
        gridentLayer.colors = [UIColor.blue.cgColor,UIColor.gray.cgColor,UIColor.black.cgColor]
        view.layer.insertSublayer(gridentLayer, at: 0)
        
        gridentLayer.startPoint = CGPoint(x: 0, y: 0)
        gridentLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gridentLayer.locations = [0,0.3,0.8,1]
    }
    
    func formatConversion(time:Float64) -> String {
        let songLengthTime = Int(time)
        let minutes = Int(songLengthTime / 60)
        let seconds = Int(songLengthTime % 60)
        var time = ""
        if minutes < 10 {
          time = "0\(minutes):"
        } else {
          time = "\(minutes)"
        }
        if seconds < 10 {
          time += "0\(seconds)"
        } else {
          time += "\(seconds)"
        }
          return time
        
    }
    
    func updatePlayerUI() {

    let duration = playItem!.asset.duration
    let seconds = CMTimeGetSeconds(duration)
    songLenght.text = formatConversion(time: seconds)
    
    }
    
 
}
