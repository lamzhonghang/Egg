//
//  ContentView.swift
//  Egg
//
//  Created by lan on 2024/11/6.
//

import HealthKit
import SwiftUI

struct StepCountView: View {
    @State private var stepCount: Double = 0.0
    @State private var walkingDistance: Double = 0.0
    @State private var walkingSpeed: Double = 0.0
    let healthStore = HKHealthStore()

    var body: some View {
        VStack {
            Text("Today's Walking Data")
                .font(.title.bold())
                .padding()

            Grid(alignment: .leading, verticalSpacing: 12) {
                GridRow {
                    Group{
                        Text("Key")
                        Text("Value")
                    }
                    .bold()
                }
                GridRow {
                    Divider()
                    Divider()
                }
                GridRow {
                    Text("Step Count")
                        .bold()
                    Text("\(Int(stepCount)) steps")
                }
                GridRow {
                    Text("Walking Distance")
                        .bold()
                    Text("\(walkingDistance, specifier: "%.2f") meters")
                }
                GridRow {
                    Text("Walking Speed")
                        .bold()
                    Text("\(walkingSpeed, specifier: "%.2f") m/s")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()

            Button("Reload Data") {
                loadWalkingData()
            }
            .padding()
        }
        .onAppear(perform: requestAuthorization)
    }

    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not available on this device.")
            return
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let speedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!
        let typesToRead: Set = [stepType, distanceType, speedType]

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                print("Authorization granted.")
                loadWalkingData()
            } else {
                print("Authorization denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func loadWalkingData() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let speedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let stepQuery = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.stepCount = 0.0
                }
                return
            }
            let steps = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                self.stepCount = steps
            }
        }

        let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.walkingDistance = 0.0
                }
                return
            }
            let distance = sum.doubleValue(for: HKUnit.meter())
            DispatchQueue.main.async {
                self.walkingDistance = distance
            }
        }

        let speedQuery = HKStatisticsQuery(quantityType: speedType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            guard let result = result, let avgSpeed = result.averageQuantity() else {
                DispatchQueue.main.async {
                    self.walkingSpeed = 0.0
                }
                return
            }
            let speed = avgSpeed.doubleValue(for: HKUnit.meter().unitDivided(by: HKUnit.second()))
            DispatchQueue.main.async {
                self.walkingSpeed = speed
            }
        }

        healthStore.execute(stepQuery)
        healthStore.execute(distanceQuery)
        healthStore.execute(speedQuery)
    }
}

struct DateView: View {
    let currentDate = Date()

    var body: some View {
        Text(currentDate, style: .time)
            .font(.custom("FusionPixel", size: 12))
    }
}

struct ProgressView: View {
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 60, height: 4)
            Rectangle()
                .frame(width: 20, height: 4)
                .opacity(0.2)
        }
    }
}

struct ContentView: View {
    @State private var animation: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                StepCountView()
//                DateView()
//                Text("842")
//                    .font(.custom("FusionPixel", size: 22))
//                ProgressView()
//                EggAni()
            }
        }
    }
}

#Preview {
    ContentView()
}
