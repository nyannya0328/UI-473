//
//  Home.swift
//  UI-473
//
//  Created by nyannyan0328 on 2022/02/22.
//

import SwiftUI
import AVFoundation

struct Home: View {
    @State var currentImage : UIImage?
    
    @State var progress : CGFloat = 0
    @State var url = URL(fileURLWithPath: Bundle.main.path(forResource: "Mountains - 59291", ofType: ".mp4") ?? "")
    var body: some View {
        VStack{
            
            
            VStack{
                HStack{
                    
                    
                    Button {
                        
                    } label: {
                        
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                   
                    NavigationLink("Done"){
                        
                            if let currentImage = currentImage {
                                
                                Image(uiImage: currentImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 300, height: 300)
                                    .cornerRadius(10)
                                   
                                
                            }
                            
                           
                        
                        
                        
                       
                          
                    }
                   
                }
             
                .overlay{
                    
                    
                    Text("Done")
                        .font(.title.weight(.bold))
                    
                    
                }
                Divider()
                    .background(.black.opacity(0.3))
                
                
                
            }
            .padding([.horizontal,.bottom])
            .frame(maxHeight:.infinity,alignment: .top)
            
            
            
            GeometryReader{proxy in
                
                let size = proxy.size
                
                ZStack{
                    
                    
                PreViewPlayer(url: $url, progress: $progress)
                        .cornerRadius(15)
                        
               
                    
                    
                    
                }
                .frame(width: size.width, height: size.height)
                
                
                
            }
            .frame(width: 200, height: 180)
            
            
            
            
            Text("To select a cover image chose a from\nyour video or an image from your camera roll.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.vertical,30)
            
            
            let size = CGSize(width: 400, height: 400)
            
            videoScroller(videoURL: $url, progress: $progress,imageSize: size,coverImage: $currentImage)
                .padding(.top,50)
                .padding(.horizontal,15)
            
            
            Button {
                
            } label: {
                
                Label {
                    
                    Text("Add From Camer Roll")
                    
                } icon: {
                    
                    Image(systemName: "plus")
                       
                }
                .font(.title2)
                .foregroundColor(.black)

            }
            .padding(.vertical)

            
            
            
            
            
            
            
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct videoScroller : View{
    
    @Binding var videoURL : URL
    @Binding var progress : CGFloat
    
    @State var imageSequence : [UIImage]?
    
    @State var offset : CGFloat = 0
    @GestureState var isDragging : Bool = false
    
    var imageSize : CGSize
    @Binding var coverImage : UIImage?
    
    var body: some View{
        
        GeometryReader{proxy in
            
            let size = proxy.size
            
            
            HStack(spacing:0){
                
                if let imageSequence = imageSequence {
                    
                    ForEach(imageSequence,id:\.self){index in
                        
                        
                        GeometryReader{proxy in
                            
                            let subSize = proxy.size
                            
                            
                            Image(uiImage: index)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: subSize.width, height: subSize.height)
                                .clipped()
                        }
                        .frame(height: size.height)
                        
                    }
                    
                    
                }
                
                
                
            }
            .cornerRadius(6)
            .overlay(alignment: .leading, content: {
                
                ZStack(alignment:.leading){
                    
                    Color.black.opacity(0.3)
                        .frame(height: size.height)
                    
                    
                    PreViewPlayer(url: $videoURL, progress: $progress)
                        .frame(width: 35, height: 60)
                        .cornerRadius(6)
                        .background(
                        
                        
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.white,lineWidth: 3)
                            .padding(-3)
                        
                        )
                        .background(
                        
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.black.opacity(0.25))
                            .padding(-5)
                        
                        )
                    
                        .offset(x: offset)
                        .gesture(
                        
                            DragGesture().updating($isDragging, body: { _, out, _ in
                                out = true
                            })
                            .onChanged({ value in
                              
                                var translaton = (isDragging ? value.location.x - 17.5 : 0)
                                
                                
                                translaton = (translaton > 0 ? translaton : 0)
                                
                                translaton = (translaton > size.width - 35 ? size.width - 35 : translaton)
                                
                                offset = translaton
                                
                                self.progress = (translaton / (size.width - 35))
                                
                            })
                            .onEnded({ _ in
                                
                                retrieveCoverImageAt(progress: progress, size: imageSize) { image in
                                    
                                    self.coverImage = image
                                    
                                }
                                
                            
                            })
                            
                        )
                    
                        
                }
                
            })
          
            .onAppear {
                
                if imageSequence == nil{
                    generateImageSequece()
                }
            }
            .onChange(of: videoURL) { _ in
                
                
               
                    
                    
                    progress = 0
                    offset = .zero
                    coverImage = nil
                    imageSequence = nil
                    
                    generateImageSequece()
                    
                retrieveCoverImageAt(progress: progress, size: imageSize) { image in
                    
                    self.coverImage = image
                    
                }
            }
            
            
            
            
        }
        .frame(height:50)
    }
    
    
    func generateImageSequece(){
        
        
        let parts = (videoDulation() / 10)
        
        
        (1..<9).forEach { index in
            
            
            let progress = (CGFloat(index) * parts) / videoDulation()
            
            
            
            retrieveCoverImageAt(progress: progress, size: CGSize(width: 100, height: 100)) { image in
                
                
                if imageSequence == nil{imageSequence = []}
                
                imageSequence?.append(image)
               
            }
            
            
        }
        
        
    }
    
    func retrieveCoverImageAt(progress : CGFloat,size : CGSize, content : @escaping(UIImage) -> ()){
        
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let asset = AVAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = size
            
            let time = CMTime(seconds: progress * videoDulation(), preferredTimescale: 600)
            
            
            do{
                
                let image = try generator.copyCGImage(at: time, actualTime: nil)
                
                let cover = UIImage(cgImage: image)
                
                
                DispatchQueue.main.async {
                    
                    
                    content(cover)
                }
                
                
            }
            catch{
                
                print(error.localizedDescription)
            }
            
            
        }
        
        
        
    }
    
    func videoDulation()->Double{
        
        let asset =  AVAsset(url: videoURL)
        
        return asset.duration.seconds
        
        
    }
}
