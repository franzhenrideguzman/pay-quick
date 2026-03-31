//
//  AppCoordinator.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation
import SwiftUI

struct AppCoordinator: View {

    @ObservedObject var appSession: AppSession
    let container: AppContainer

    var body: some View {
        Group {
            if appSession.isAuthenticated {
                TransactionListView(
                    viewModel: container.makeTransactionListViewModel()
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                LoginView(
                    viewModel: container.makeLoginViewModel()
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal:   .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(duration: 0.35), value: appSession.isAuthenticated)
    }
}
