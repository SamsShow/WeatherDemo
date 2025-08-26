//
//  WeatherView.swift
//  WeatherDemo
//
//  Created by Saksham Tyagi on 25/08/25.
//

//
//  WeatherView.swift
//  WeatherDemo
//
//  Created by Saksham Tyagi on 25/08/25.
//

//
//  WeatherView.swift
//  WeatherDemo
//
//  Created by Saksham Tyagi on 25/08/25.
//

import SwiftUI

struct WeatherView: View {
    var weather: WeatherManager.ResponseBody
    @State private var animateBackground = false
    @State private var animateCards = false
    @State private var animateTemp = false
    @State private var showDetails = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic animated background
                AnimatedBackground(weatherType: weather.weather[0].main)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Floating header with blur effect
                        HeaderSection(weather: weather)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -50)
                        
                        // Main temperature card with parallax
                        MainWeatherCard(weather: weather, animateTemp: $animateTemp)
                            .padding(.top, 40)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 100)
                        
                        // Interactive weather metrics
                        WeatherMetricsGrid(weather: weather)
                            .padding(.top, 30)
                            .opacity(showDetails ? 1 : 0)
                            .offset(y: showDetails ? 0 : 50)
                        
                        // Extended forecast preview
                        ForecastPreview()
                            .padding(.top, 20)
                            .opacity(showDetails ? 1 : 0)
                            .offset(y: showDetails ? 0 : 30)
                    }
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                
                // Floating particles overlay
                ParticleOverlay(weatherType: weather.weather[0].main)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 1.2)) {
            animateBackground = true
            animateCards = true
        }
        
        withAnimation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0).delay(0.3)) {
            animateTemp = true
        }
        
        withAnimation(.easeInOut(duration: 0.8).delay(0.8)) {
            showDetails = true
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    let weather: WeatherManager.ResponseBody
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weather.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(getCurrentTime())
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d • h:mm a"
        return formatter.string(from: Date())
    }
}

// MARK: - Main Weather Card
struct MainWeatherCard: View {
    let weather: WeatherManager.ResponseBody
    @Binding var animateTemp: Bool
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Glassmorphism background
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.25), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
            
            VStack(spacing: 20) {
                // Weather icon with animation
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    Image(systemName: weatherIcon(for: weather.weather[0].main))
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(iconColor(for: weather.weather[0].main))
                        .scaleEffect(animateTemp ? 1.0 : 0.3)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateTemp)
                }
                
                // Temperature with counter animation
                HStack(alignment: .top, spacing: 8) {
                    AnimatedTemperature(
                        temperature: weather.main.feelsLike.roundDouble(),
                        animate: animateTemp
                    )
                    
                    Text("°")
                        .font(.system(size: 40, weight: .ultraLight))
                        .foregroundStyle(.white)
                        .offset(y: 8)
                }
                
                // Weather description
                VStack(spacing: 8) {
                    Text(weather.weather[0].main)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("Feels like \(weather.main.temp.roundDouble())°")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            pulseAnimation = true
        }
    }
    
    private func weatherIcon(for weather: String) -> String {
        switch weather.lowercased() {
        case "clear": return "sun.max.fill"
        case "clouds": return "cloud.fill"
        case "rain", "drizzle": return "cloud.rain.fill"
        case "snow": return "cloud.snow.fill"
        case "thunderstorm": return "cloud.bolt.rain.fill"
        case "mist", "fog", "haze": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
    
    private func iconColor(for weather: String) -> LinearGradient {
        switch weather.lowercased() {
        case "clear":
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "rain", "drizzle":
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "snow":
            return LinearGradient(colors: [.white, .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "thunderstorm":
            return LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Animated Temperature
struct AnimatedTemperature: View {
    let temperature: String
    let animate: Bool
    @State private var displayTemp: Int = 0
    
    var body: some View {
        Text("\(displayTemp)")
            .font(.system(size: 80, weight: .ultraLight, design: .rounded))
            .foregroundStyle(.white)
            .contentTransition(.numericText())
            .onChange(of: animate) { _, newValue in
                if newValue, let temp = Int(temperature) {
                    animateToTemperature(temp)
                }
            }
    }
    
    private func animateToTemperature(_ target: Int) {
        let duration = 1.5
        let steps = 30
        let increment = Double(target) / Double(steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (duration / Double(steps)) * Double(step)) {
                withAnimation(.easeOut(duration: 0.05)) {
                    displayTemp = Int(Double(step) * increment)
                }
            }
        }
    }
}

// MARK: - Weather Metrics Grid
struct WeatherMetricsGrid: View {
    let weather: WeatherManager.ResponseBody
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            MetricCard(
                icon: "thermometer.low",
                title: "Min Temp",
                value: weather.main.tempMin.roundDouble() + "°",
                color: .blue
            )
            
            MetricCard(
                icon: "thermometer.high",
                title: "Max Temp",
                value: weather.main.tempMax.roundDouble() + "°",
                color: .red
            )
            
            MetricCard(
                icon: "wind",
                title: "Wind Speed",
                value: weather.wind.speed.roundDouble() + " m/s",
                color: .green
            )
            
            MetricCard(
                icon: "humidity.fill",
                title: "Humidity",
                value: "\(weather.main.humidity)%",
                color: .cyan
            )
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
            
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                VStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.vertical, 20)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Forecast Preview
struct ForecastPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Next Hours")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<8) { hour in
                        HourlyForecastCard(hour: hour)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
}

// MARK: - Hourly Forecast Card
struct HourlyForecastCard: View {
    let hour: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("\(hour + 1)h")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
            
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 24))
                .foregroundStyle(.yellow)
            
            Text("\(Int.random(in: 20...30))°")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Animated Background
struct AnimatedBackground: View {
    let weatherType: String
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: backgroundColors(for: weatherType)),
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true), value: animateGradient)
            
            // Overlay gradient for depth
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.1), .clear, .black.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .onAppear {
            animateGradient = true
        }
    }
    
    private func backgroundColors(for weather: String) -> [Color] {
        switch weather.lowercased() {
        case "clear":
            return [Color(hue: 0.6, saturation: 0.8, brightness: 0.9), Color(hue: 0.55, saturation: 0.9, brightness: 0.7)]
        case "clouds":
            return [Color(hue: 0.6, saturation: 0.4, brightness: 0.7), Color(hue: 0.65, saturation: 0.6, brightness: 0.5)]
        case "rain", "drizzle":
            return [Color(hue: 0.65, saturation: 0.8, brightness: 0.6), Color(hue: 0.7, saturation: 0.7, brightness: 0.4)]
        case "snow":
            return [Color(hue: 0.6, saturation: 0.3, brightness: 0.9), Color(hue: 0.65, saturation: 0.4, brightness: 0.7)]
        default:
            return [Color(hue: 0.656, saturation: 0.787, brightness: 0.454), Color(hue: 0.656, saturation: 0.787, brightness: 0.354)]
        }
    }
}

// MARK: - Particle Overlay
struct ParticleOverlay: View {
    let weatherType: String
    
    var body: some View {
        ZStack {
            if weatherType.lowercased().contains("rain") {
                RainParticles()
            } else if weatherType.lowercased().contains("snow") {
                SnowParticles()
            }
        }
    }
}

struct RainParticles: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<15) { _ in
                Rectangle()
                    .fill(.white.opacity(0.6))
                    .frame(width: 2, height: 20)
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: animate ? 1000 : -100
                    )
                    .animation(
                        .linear(duration: Double.random(in: 1.0...2.0))
                        .repeatForever(autoreverses: false),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct SnowParticles: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20) { _ in
                Circle()
                    .fill(.white.opacity(0.8))
                    .frame(width: CGFloat.random(in: 3...8))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: animate ? 1000 : -100
                    )
                    .animation(
                        .linear(duration: Double.random(in: 3.0...6.0))
                        .repeatForever(autoreverses: false),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    WeatherView(weather: previewWeather)
}
