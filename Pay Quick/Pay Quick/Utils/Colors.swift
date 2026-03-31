//
//  Colors.swift
//  Pay Quick
//
//  Created by Franz Henri De Guzman on 3/31/26.
//

import Foundation
import SwiftUI

// MARK: - Colors
extension Color {
    static let pqBlue      = Color(red: 0.102, green: 0.337, blue: 0.859)  // #1A56DB
    static let pqBlueDark  = Color(red: 0.075, green: 0.251, blue: 0.659)  // #1340A8
    static let pqGreen     = Color(red: 0.133, green: 0.773, blue: 0.369)  // #22C55E
    static let pqRed       = Color(red: 0.937, green: 0.267, blue: 0.267)  // #EF4444
    static let pqBgLight   = Color(red: 0.973, green: 0.980, blue: 1.0)    // #F8FAFF
    static let pqSurface   = Color(uiColor: .systemBackground)
    static let pqSurfaceRaised = Color(uiColor: .secondarySystemBackground)
    static let pqTextPrimary   = Color(uiColor: .label)
    static let pqTextSecondary = Color(uiColor: .secondaryLabel)
    static let pqTextTertiary  = Color(uiColor: .tertiaryLabel)
}

// MARK: - Typography
extension Font {
    static let pqLargeTitle  = Font.system(size: 34, weight: .bold,     design: .rounded)
    static let pqTitle1      = Font.system(size: 28, weight: .bold,     design: .rounded)
    static let pqTitle2      = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let pqHeadline    = Font.system(size: 17, weight: .semibold, design: .default)
    static let pqBody        = Font.system(size: 17, weight: .regular,  design: .default)
    static let pqSubheadline = Font.system(size: 15, weight: .regular,  design: .default)
    static let pqCaption     = Font.system(size: 12, weight: .regular,  design: .default)
    static let pqCaptionBold = Font.system(size: 12, weight: .semibold, design: .default)
    static let pqMono        = Font.system(size: 14, weight: .regular,  design: .monospaced)
}

// MARK: - Spacing
enum PQSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
enum PQRadius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 24
    static let pill: CGFloat = 100
}
