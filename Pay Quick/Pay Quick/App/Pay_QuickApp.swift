//
//  Pay_QuickApp.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/30/26.
//

import SwiftUI
import Combine

@main
struct PayQuickApp: App {

    @StateObject private var container = AppContainerWrapper()

    var body: some Scene {
        WindowGroup {
            AppCoordinator(
                appSession: container.instance.appSession,
                container: container.instance
            )
            .environmentObject(container.instance.appSession)
        }
    }
}

// MARK: - AppContainerWrapper
@MainActor
private final class AppContainerWrapper: ObservableObject {
    let instance: AppContainer
    init() { instance = AppContainer() }
}
