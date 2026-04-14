//
//  NotificationManager.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/14/26.
//

import Foundation
import UserNotifications

enum NotificationManager {

    /// Request notification authorization. Safe to call multiple times;
    /// the system prompt only appears once.
    static func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
        }
    }

    /// Clear all pending notifications, then schedule one for each
    /// watch that hasn't been worn in 90+ days.
    static func scheduleUnwornReminders(for watches: [Watch]) async {
        let center = UNUserNotificationCenter.current()

        // Always clear first to avoid duplicates
        center.removeAllPendingNotificationRequests()

        let stats = WatchStatistics(watches: watches)
        let unworn = stats.notWornIn90Days

        for watch in unworn {
            let content = UNMutableNotificationContent()
            content.title = "Watch Reminder"
            content.body = "Your \(watch.brand) \(watch.model) hasn't been worn in over 90 days. Give it some wrist time!"
            content.sound = .default

            // Fire 5 seconds from now
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 5,
                repeats: false
            )

            let id = "unworn-\(watch.brand)-\(watch.model)"
            let request = UNNotificationRequest(
                identifier: id,
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                print("Failed to schedule notification for \(watch.brand) \(watch.model): \(error.localizedDescription)")
            }
        }
    }
}
