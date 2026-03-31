//
//  PQComponents.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation
import SwiftUI

// MARK: - PQButton

struct PQButton: View {
    let title: String
    var style: PQButtonStyle = .primary
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.pqHeadline)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: PQRadius.md))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: PQRadius.md)
                        .strokeBorder(Color.pqBlue, lineWidth: 1.5)
                }
            }
        }
        .disabled(isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:     return .pqBlue
        case .secondary:   return .clear
        case .destructive: return .pqRed
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:     return .white
        case .secondary:   return .pqBlue
        case .destructive: return .white
        }
    }
}

// MARK: - PQButtonStyle

enum PQButtonStyle {
    case primary
    case secondary
    case destructive
}

// MARK: - PQTextField

struct PQTextField: View {
    let label: String
    var placeholder: String = ""
    var isSecure: Bool = false
    @Binding var text: String

    @FocusState private var isFocused: Bool
    @State private var isRevealed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: PQSpacing.xs) {
            Text(label)
                .font(.pqCaption)
                .foregroundStyle(Color.pqTextSecondary)
                .textCase(.uppercase)
                .kerning(0.5)

            HStack {
                Group {
                    if isSecure && !isRevealed {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(.pqBody)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .foregroundStyle(Color.pqTextTertiary)
                    }
                }
            }
            .padding(.horizontal, PQSpacing.md)
            .padding(.vertical, PQSpacing.md)
            .background(Color.pqSurfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: PQRadius.sm))
            .overlay {
                RoundedRectangle(cornerRadius: PQRadius.sm)
                    .strokeBorder(
                        isFocused ? Color.pqBlue : Color.clear,
                        lineWidth: 2
                    )
            }
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
    }
}
