//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct RealmsFAB<Destination: View>: View {
    let size: CGFloat = 64
    let destination: () -> Destination
    
    @State private var isPressed = false
    private let pressedOpacity = 0.7
    
    var body: some View {
        NavigationLink(destination: destination()) {
            ZStack {
                Circle().fill(Color.compound.bgCanvasDefault)
                Circle().fill(LinearGradient(gradient: .compound.action, startPoint: .top, endPoint: .bottom))
                    .opacity(0.04)
                Circle().strokeBorder(LinearGradient(gradient: .compound.action, startPoint: .top, endPoint: .bottom))
                CompoundIcon(\.extensions, size: .custom(size * 0.45), relativeTo: .compound.bodyLG)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .opacity(isPressed ? pressedOpacity : 1)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    NavigationStack {
        RealmsFAB {
            Text("Destination View")
        }
    }
}
