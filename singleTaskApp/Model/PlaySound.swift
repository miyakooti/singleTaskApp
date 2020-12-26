//
//  PlaySound.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/26.
//

import Foundation
import AVFoundation

class PlaySound{
    
    var player:AVAudioPlayer? //playerインスタンスを作成
//    ファイル名と拡張子
    func playSound(fileName:String, extensionName:String){
        let soundURL = Bundle.main.url(forResource: fileName, withExtension: extensionName)
        do {
            //効果音を鳴らす
            player = try AVAudioPlayer(contentsOf: soundURL!)
            player?.play()
        } catch {
//                エラーをキャッチしたときの処理
            print("エラーです")
        }
    }
    
    
}
