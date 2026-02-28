import SwiftUI

struct InfoView: View {
    
    @State private var goToSceneOne = false
    let biptyaColor = Color(red: 181/255, green: 103/255, blue: 13/255)
    
    var body: some View {
        ZStack {
            // Background Layer
            Color.black.ignoresSafeArea()
            
            Image("LeopardDetail")
                .resizable()
                .scaledToFill()
                .opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 10) {
                    // ... (Title text remains the same)
                    Text("In Maharashtra, India,")
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(alignment: .lastTextBaseline, spacing: 15) {
                        // ... (Title text remains the same)
                        Text("LEOPARDS ARE CALLED")
                            .font(.system(size: 24, weight: .bold))
                            .tracking(4)
                            .foregroundColor(.white)
                        
                        ZStack {
                            Group {
                                Text("BIBTYA").offset(x:  1, y:  1)
                                Text("BIBTYA").offset(x: -1, y:  1)
                                Text("BIBTYA").offset(x:  1, y: -1)
                                Text("BIBTYA").offset(x: -1, y: -1)
                            }
                            .foregroundColor(.white)
                            
                            Text("BIBTYA")
                                .foregroundColor(biptyaColor)
                        }
                        .font(.custom("LostinSouth", size: 64))
                    }
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(biptyaColor.opacity(0.5))
                    .frame(width: 300)
                
                Text("Every choice you make affects their survival.")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                // Static prompt (since the whole screen is now the button)
                HStack {
                    Text("Tap anywhere to begin")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Image(systemName: "chevron.right.2")
                        .foregroundColor(biptyaColor)
                        .font(.system(size: 18, weight: .bold))
                }
                .padding(.bottom, 50)
            }
        }
        // --- ADDED THIS TO MAKE THE WHOLE SCREEN TAPPABLE ---
        .contentShape(Rectangle())
        .onTapGesture {
            goToSceneOne = true
        }
        // ----------------------------------------------------
        .navigationDestination(isPresented: $goToSceneOne) {
            SceneOneView()
        }
        .navigationBarBackButtonHidden(true)
    }
}
