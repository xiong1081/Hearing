//
//  AudioRecorder.swift
//  Hearing
//
//  Created by 李招雄 on 2020/5/24.
//  Copyright © 2020 李招雄. All rights reserved.
//

import AVFoundation

class AudioRecorder: NSObject {
    static let shared = AudioRecorder()
    
    let captureSession = AVCaptureSession()
    
    func record() {
        do {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted: break
            case .denied: return
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in

                }
                return
            default: break
            }
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
//            let format = AVAudioFormat(standardFormatWithSampleRate: 8000, channels: 2)
//            guard let f = format else { return }
//            let url = URL(fileURLWithPath: NSTemporaryDirectory().appending("record"))
//            let recorder = try AVAudioRecorder(url: url, format: f)
//            recorder.delegate = self
            // input
            guard let device = AVCaptureDevice.default(for: .audio) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            // output
            let output = AVCaptureAudioDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    
    func stop() {
        captureSession.stopRunning()
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    
}

extension AudioRecorder: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var abl = AudioBufferList()
        var data = Data()
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, bufferListSizeNeededOut: nil, bufferListOut: &abl, bufferListSize: MemoryLayout.size(ofValue: abl), blockBufferAllocator: nil, blockBufferMemoryAllocator: nil, flags: 0, blockBufferOut: nil)
        let buffers = UnsafeBufferPointer<AudioBuffer>(start: &abl.mBuffers, count: Int(abl.mNumberBuffers))
        for buffer in buffers {
            let d = buffer.mData?.assumingMemoryBound(to: UInt8.self)
            data.append(d!, count: Int(buffer.mDataByteSize))
        }
        do {
            let player = try AVAudioPlayer(data: data)
            player.play()
        } catch {
            print(error)
        }
    }
}
