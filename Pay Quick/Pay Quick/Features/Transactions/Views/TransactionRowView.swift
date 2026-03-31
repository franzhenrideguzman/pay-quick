//
//  TransactionRowView.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation
import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: PQSpacing.md) {
            typeIcon
            details
            Spacer(minLength: PQSpacing.sm)
            amountAndStatus
        }
        .padding(.horizontal, PQSpacing.md)
        .padding(.vertical, PQSpacing.md)
        .background(Color.pqSurface)
    }

    // MARK: - Icon

    private var typeIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 44, height: 44)

            Image(systemName: iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconForegroundColor)
        }
    }

    // MARK: - Details

    private var details: some View {
        VStack(alignment: .leading, spacing: PQSpacing.xs) {
            Text(transaction.type.displayName)
                .font(.pqHeadline)
                .foregroundStyle(Color.pqTextPrimary)
                .lineLimit(1)

            Text(transaction.destinationId)
                .font(.pqCaption)
                .foregroundStyle(Color.pqTextTertiary)
                .lineLimit(1)

            Text(transaction.createdAt.formatted(
                .dateTime.day().month(.abbreviated).year().hour().minute()
            ))
            .font(.pqCaption)
            .foregroundStyle(Color.pqTextSecondary)
        }
    }

    // MARK: - Amount and Status

    private var amountAndStatus: some View {
        VStack(alignment: .trailing, spacing: PQSpacing.xs) {
            Text(transaction.formattedAmount)
                .font(.pqHeadline)
                .foregroundStyle(amountColor)
                .monospacedDigit()

            statusBadge
        }
    }

    private var statusBadge: some View {
        Text(transaction.status.rawValue.capitalized)
            .font(.pqCaptionBold)
            .foregroundStyle(statusForeground)
            .padding(.horizontal, PQSpacing.sm)
            .padding(.vertical, 2)
            .background(statusForeground.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Helpers

    private var iconName: String {
        switch transaction.type {
        case .transfer: return "arrow.up.right"
        case .topUp:    return "arrow.down.left"
        }
    }

    private var iconBackgroundColor: Color {
        switch transaction.type {
        case .transfer: return Color.pqBlue.opacity(0.12)
        case .topUp:    return Color.pqGreen.opacity(0.12)
        }
    }

    private var iconForegroundColor: Color {
        switch transaction.type {
        case .transfer: return Color.pqBlue
        case .topUp:    return Color.pqGreen
        }
    }

    private var amountColor: Color {
        switch transaction.type {
        case .transfer: return Color.pqTextPrimary
        case .topUp:    return Color.pqGreen
        }
    }

    private var statusForeground: Color {
        switch transaction.status {
        case .success: return Color.pqGreen
        case .pending: return Color(red: 0.96, green: 0.62, blue: 0.04)
        case .failed:  return Color.pqRed
        case .unknown: return Color.pqTextSecondary
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        TransactionRowView(
            transaction: Transaction(
                id: "1",
                amountInCents: 5000,
                currency: "USD",
                type: .transfer,
                status: .success,
                createdAt: Date(),
                destinationId: "wal_20251009-TRF5"
            )
        )
        Divider()
            .padding(.leading, 74)
        TransactionRowView(
            transaction: Transaction(
                id: "2",
                amountInCents: 10000,
                currency: "USD",
                type: .topUp,
                status: .success,
                createdAt: Date().addingTimeInterval(-3600),
                destinationId: "wal_20251009-001TP"
            )
        )
    }
}
