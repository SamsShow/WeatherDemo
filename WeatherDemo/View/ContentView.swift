//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Saksham Tyagi on 20/08/25.
//

//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Saksham Tyagi on 20/08/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: WeatherManager.ResponseBody?
    @State private var isAppearing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isRefreshing = false
    
    var body: some View {
        ZStack {
            // Dynamic background based on current state
            AnimatedAppBackground(
                hasWeather: weather != nil,
                weatherType: weather?.weather.first?.main ?? "Clear"
            )
            
            Group {
                if let location = locationManager.location {
                    if let weather = weather {
                        // Weather data loaded - show main weather view
                        WeatherView(weather: weather)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.9)),
                                removal: .opacity
                            ))
                            .onAppear {
                                scheduleWeatherRefresh()
                            }
                            .refreshable {
                                await refreshWeatherData(location: location)
                            }
                    } else {
                        // Location available but loading weather
                        EnhancedLoadingView(message: "Fetching weather data...")
                            .transition(.opacity)
                            .task {
                                await loadWeatherData(location: location)
                            }
                    }
                } else {
                    // No location - show welcome or loading
                    if locationManager.isLoading {
                        EnhancedLoadingView(message: "Getting your location...")
                            .transition(.opacity)
                    } else {
                        WelcomeView()
                            .environmentObject(locationManager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                }
            }
            .scaleEffect(isAppearing ? 1.0 : 0.95)
            .opacity(isAppearing ? 1.0 : 0)
            
            // Error overlay
            if showError {
                ErrorOverlay(
                    message: errorMessage,
                    onRetry: {
                        if let location = locationManager.location {
                            Task {
                                await loadWeatherData(location: location)
                            }
                        } else {
                            locationManager.requestLocation()
                        }
                    },
                    onDismiss: {
                        withAnimation(.spring()) {
                            showError = false
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
            
            // Refresh indicator
            if isRefreshing {
                VStack {
                    RefreshIndicator()
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: weather != nil)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: locationManager.location != nil)
        .animation(.spring(), value: showError)
        .animation(.spring(), value: isRefreshing)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.1)) {
                isAppearing = true
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func loadWeatherData(location: CLLocationCoordinate2D) async {
        do {
            weather = try await weatherManager.getCurrentWeather(
                latitude: location.latitude,
                longitude: location.longitude
            )
        } catch {
            handleWeatherError(error)
        }
    }
    
    @MainActor
    private func refreshWeatherData(location: CLLocationCoordinate2D) async {
        isRefreshing = true
        
        do {
            let newWeather = try await weatherManager.getCurrentWeather(
                latitude: location.latitude,
                longitude: location.longitude
            )
            
            // Delay for better UX
            try await Task.sleep(nanoseconds: 500_000_000)
            
            withAnimation(.spring()) {
                weather = newWeather
                isRefreshing = false
            }
        } catch {
            isRefreshing = false
            handleWeatherError(error)
        }
    }
    
    private func handleWeatherError(_ error: Error) {
        errorMessage = "Unable to fetch weather data. Please check your connection and try again."
        withAnimation(.spring()) {
            showError = true
        }
        
        // Auto-dismiss error after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation(.spring()) {
                showError = false
            }
        }
    }
    
    private func scheduleWeatherRefresh() {
        // Auto-refresh every 10 minutes
        Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { _ in
            guard let location = locationManager.location else { return }
            Task {
                await refreshWeatherData(location: location)
            }
        }
    }
}

// MARK: - Enhanced Loading View
struct EnhancedLoadingView: View {
    let message: String
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var dotOpacity: [Double] = [1.0, 0.6, 0.3]
    
    var body: some View {
        ZStack {
            // Background blur
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Animated weather icon
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(pulseScale)
                }
                
                VStack(spacing: 12) {
                    Text(message)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                    
                    // Animated dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(.white)
                                .frame(width: 8, height: 8)
                                .opacity(dotOpacity[index])
                        }
                    }
                }
            }
        }
        .onAppear {
            startLoadingAnimations()
        }
    }
    
    private func startLoadingAnimations() {
        // Rotation animation
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
        
        // Dot animation
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                let first = dotOpacity.removeFirst()
                dotOpacity.append(first)
            }
        }
    }
}

// MARK: - Error Overlay
struct ErrorOverlay: View {
    let message: String
    let onRetry: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Rectangle()
                .fill(.black.opacity(0.4))
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 20) {
                // Error icon
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.red)
                }
                
                VStack(spacing: 12) {
                    Text("Oops!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(message)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                HStack(spacing: 16) {
                    Button("Dismiss") {
                        onDismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Retry") {
                        onDismiss()
                        onRetry()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(30)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Refresh Indicator
struct RefreshIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)
            
            Text("Refreshing weather data...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.top, 50)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Animated App Background
struct AnimatedAppBackground: View {
    let hasWeather: Bool
    let weatherType: String
    @State private var animateGradient = false
    
    var body: some View {
        if hasWeather {
            // Weather-based background (handled by WeatherView)
            Color.clear
        } else {
            // Default app background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hue: 0.6, saturation: 0.8, brightness: 0.4),
                    Color(hue: 0.65, saturation: 0.9, brightness: 0.6)
                ]),
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: animateGradient)
            .ignoresSafeArea()
            .onAppear {
                animateGradient = true
            }
        }
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.blue, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.white.opacity(0.2), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
