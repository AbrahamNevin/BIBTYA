import SwiftUI
import Charts

// MARK: - Data Models
struct LeopardData: Identifiable {
    let id = UUID()
    let year: Int
    let deaths: Int
}

struct CrossingData: Identifiable {
    let id = UUID()
    let year: Int
    let crossings: Int
}

struct CoexistenceEndingView: View {
    // --- CHOICE TRACKING ---
    // Set this to true if Build Corridor -> Use Corridor was chosen.
    // Otherwise, Flow2 will be shown.
    var didBuildAndUseCorridor: Bool = true
    var useLivingCorridorPath: Bool
    
    @State private var stage: Int = 0
    @State private var showLine1 = false
    @State private var showLine2 = false
    @State private var showLine3 = false
    @State private var goToSceneOne = false
    
    let mortalityData: [LeopardData] = [
        .init(year: 2012, deaths: 14), .init(year: 2013, deaths: 16),
        .init(year: 2014, deaths: 18), .init(year: 2015, deaths: 21),
        .init(year: 2016, deaths: 24), .init(year: 2017, deaths: 12),
        .init(year: 2018, deaths: 9), .init(year: 2019, deaths: 7),
        .init(year: 2020, deaths: 5)
    ]
    
    let crossingData: [CrossingData] = [
        .init(year: 2014, crossings: 38),
        .init(year: 2016, crossings: 52),
        .init(year: 2018, crossings: 74),
        .init(year: 2020, crossings: 91)
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    // --- DYNAMIC BACKGROUND LAYER ---
                    Group {
                        if stage >= 1 && stage < 4 {
                            Image("CoexistenceBackground")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .ignoresSafeArea()
                                .overlay(Color.black.opacity(0.5))
                                .transition(.opacity)
                        } else if stage == 4 {
                            // Stage 4: Switches background based on user choice
                            Image(useLivingCorridorPath ? "Flow1" : "Flow2")
                                        .resizable()
                                        .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .ignoresSafeArea()
                                .overlay(Color.black.opacity(0.6))
                                .transition(.opacity)
                        }
                    }
                    
                    // --- OVERLAY CONTENT (Text & Button) ---
                    VStack {
                        if stage == 1 {
                            Spacer()
                            Text("“Progress is not just measured in kilometers of road,\nbut in lives safely preserved alongside it.”")
                                .font(.system(size: 24, weight: .medium, design: .serif))
                                .italic()
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(40)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            Spacer()
                        }
                        
                        if stage == 4 {
                            Spacer()
                            VStack(spacing: 25) {
                                if showLine1 {
                                    Text("“When roads slow down, forests breathe.”")
                                        .italic()
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                                
                                if showLine2 {
                                    Text("“Between 2016 and 2020, leopard deaths fell by over 75%.”")
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                                
                                if showLine3 {
                                    VStack(spacing: 40) {
                                        Text("“Coexistence is not an idea. It is infrastructure.”")
                                            .fontWeight(.black)
                                        
                                        // PLAY AGAIN BUTTON - Centered on top of Flow1/Flow2
                                        Button(action: {
                                            goToSceneOne = true
                                        }) {
                                            HStack {
                                                Image(systemName: "arrow.counterclockwise")
                                                Text("Play Again")
                                            }
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 24)
                                            .background(Capsule().stroke(Color.white, lineWidth: 2))
                                            .background(Color.black.opacity(0.4).clipShape(Capsule()))
                                        }
                                    }
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .font(.system(size: 24, weight: .medium, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(40)
                            Spacer()
                        }
                    }
                    
                    // --- DATA VISUALIZATION (Stage 2 & 3) ---
                    VStack(spacing: 30) {
                        if stage == 2 {
                            chartContainer(title: "Leopard Mortality (Before vs After Mitigation)", data: mortalityChart)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                        }
                        
                        if stage == 3 {
                            chartContainer(title: "Wildlife Crossings Per Month (Line Trend)", data: crossingChart)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                        }
                    }
                    .padding()

                    // --- INITIAL TITLE CARD ---
                    if stage == 0 {
                        ZStack {
                            Color.black.ignoresSafeArea()
                            Text("ACT III: The Living Corridor")
                                .font(.system(size: 32, weight: .black, design: .serif))
                                .tracking(6)
                                .foregroundColor(.white)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .onAppear {
                runEndingSequence()
            }
            .navigationDestination(isPresented: $goToSceneOne) {
                SceneOneView()
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    // --- Helper Components ---
    private func chartContainer<Content: View>(title: String, data: Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            data
                .frame(height: 450)
            Text("Data represents trends from the NH44 Wildlife Corridor.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(Color.black.opacity(0.7).cornerRadius(15))
    }

    private var mortalityChart: some View {
        Chart(mortalityData) { item in
            LineMark(x: .value("Year", item.year), y: .value("Deaths", item.deaths))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 3))
            
            PointMark(x: .value("Year", item.year), y: .value("Deaths", item.deaths))
                .annotation(position: .top) {
                    Text("\(item.deaths)").font(.caption2).foregroundColor(.white)
                }
        }
        .chartXScale(domain: 2011...2021)
    }

    private var crossingChart: some View {
        Chart(crossingData) { item in
            LineMark(x: .value("Year", String(item.year)), y: .value("Crossings", item.crossings))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.green.gradient)
                .lineStyle(StrokeStyle(lineWidth: 3))

            PointMark(x: .value("Year", String(item.year)), y: .value("Crossings", item.crossings))
                .annotation(position: .top) {
                    Text("\(item.crossings)").font(.caption2).foregroundColor(.white)
                }
        }
    }

    func runEndingSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 1.5)) { stage = 1 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            withAnimation(.easeInOut) { stage = 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.5) {
            withAnimation(.easeInOut) { stage = 3 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 19.0) {
            withAnimation(.easeInOut) { stage = 4 }
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) { showLine1 = true }
            withAnimation(.easeInOut(duration: 1.0).delay(2.5)) { showLine2 = true }
            withAnimation(.easeInOut(duration: 1.0).delay(4.5)) { showLine3 = true }
        }
    }
}
