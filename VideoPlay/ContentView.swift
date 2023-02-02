//
//  ContentView.swift
//  VideoPlay
//
//  Created by Guru Mahan on 02/01/23.
//

import SwiftUI
import AVKit
struct ContentView: View {
//    let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"  )!
//    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"
  //"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
         
    
   @State var player = AVPlayer(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!)
    @State var isplaying = false
    @State var showControls = false
    @State var value: Float = 0
    var body: some View {
        NavigationStack{
            VStack {
                ZStack{
                    VideoPlayer(player: $player)
                    if self.showControls{
                        Control(player: self.$player,isplaying: self.$isplaying,pannel: $showControls, value: self.$value)
                    }
                   
                }
                .frame(height: UIScreen.main.bounds.height / 3.5)
                .onTapGesture {
                    self.showControls = true
                }
                
                Spacer()
            }
            .onAppear{
                self.player.play()
                self.isplaying = true
                
            }
          
        }
        
    }
}

struct VideoPlayer : UIViewControllerRepresentable{

    @Binding var player : AVPlayer
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoPlayer>) -> AVPlayerViewController {
        
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resize
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<VideoPlayer>) {
        
    }
}

struct Control: View{
    
    @Binding var player : AVPlayer
    @Binding var isplaying : Bool
    @Binding var pannel : Bool
    @Binding var value : Float
    var body: some View{
        VStack{
            Spacer()
            
            HStack{
                Button {
                    self.player.seek(to: CMTime(seconds: self.getSeconds() - 3  , preferredTimescale: 1))

                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(20)
                }
                Spacer()
                
                Button {
                    
                    if self.isplaying{
                        self.player.pause()
                        self.isplaying = false
                    }else{
                        self.player.play()
                        self.isplaying = true
                    }
                    
                } label: {
                    Image(systemName:self.isplaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(20)
                }
                Spacer()
                Button {
                    self.player.seek(to: CMTime(seconds: self.getSeconds() + 3
                                                , preferredTimescale: 1))
                    
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(20)
                }

            }
            Spacer()
            CustomProgressBar(value: self.$value, player:self.$player, isplaying: self.$isplaying)
        } .padding()
        .background(Color.black.opacity(0.4))
        .onTapGesture {
            
            self.pannel = false
        }
        .onAppear{
            self.player.addPeriodicTimeObserver(forInterval: CMTime(seconds:1,preferredTimescale: 1), queue: .main) { (_) in
                self.value = self.getSliderValue()
            }
        }
           
    }
    func getSliderValue()->Float{
        return Float(self.player.currentTime().seconds /
                     (self.player.currentItem?.duration.seconds)!)
    }
   
    func getSeconds()-> Double{
        
        return Double(Double(self.value) *
                     (self.player.currentItem?.duration.seconds)!)
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct CustomProgressBar : UIViewRepresentable {
 
    func makeCoordinator() -> CustomProgressBar.Coordinator {
        return CustomProgressBar.Coordinator(parent1: self)
    }
    
    @Binding var value: Float
    @Binding var player: AVPlayer
    @Binding var isplaying: Bool
    
    func makeUIView(context: UIViewRepresentableContext<CustomProgressBar>) -> UISlider{
        
        let slider = UISlider()
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .gray
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slider.value = value
        slider.addTarget(context.coordinator, action: #selector(context.coordinator.changed(slider:)) , for: .valueChanged)
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: UIViewRepresentableContext<CustomProgressBar>) {
        uiView.value = value
    }
    
    class Coordinator : NSObject {
        var parent : CustomProgressBar
        
        init(parent1: CustomProgressBar) {
            self.parent = parent1
        }
        
        @objc func changed(slider: UISlider){
            
            if slider.isTracking{
                parent.player.pause()
                
                let sec = Double(slider.value * Float((parent.player.currentItem?.duration.seconds)!))
                
                parent.player.seek(to: CMTime(seconds: sec, preferredTimescale: 1))
                
            }else{
                let sec = Double(slider.value * Float((parent.player.currentItem?.duration.seconds)!))
                parent.player.seek(to: CMTime(seconds: sec, preferredTimescale: 1))
                
                if parent.isplaying{
                    parent.player.play()
                }
            }
        }
    }
}

class Host: UIHostingController<ContentView>{
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}
