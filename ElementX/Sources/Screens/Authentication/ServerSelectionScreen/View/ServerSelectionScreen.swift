//
// Copyright 2022-2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import ReactBrownfield
import SwiftUI

struct ServerSelectionScreen: View {
    @Bindable var context: ServerSelectionScreenViewModel.Context
    @State private var showingHostedServerSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.top, UIConstants.iconTopPaddingToNavigationBar)
                    .padding(.bottom, 36)
                
                serverForm
                
                hostedServerPromo
                    .padding(.top, 24)
            }
            .readableFrame()
            .padding(.horizontal, 16)
        }
        .background(Color.compound.bgCanvasDefault.ignoresSafeArea())
        .toolbar { toolbar }
        .alert(item: $context.alertInfo)
        .interactiveDismissDisabled()
        .sheet(isPresented: $showingHostedServerSheet) {
            ReactNativeView(moduleName: "Realms")
        }
    }
    
    /// The title, message and icon at the top of the screen.
    var header: some View {
        VStack(spacing: 8) {
            Image(asset: Asset.Images.serverSelectionIcon)
                .bigIcon(insets: 19)
                .padding(.bottom, 8)
            
            Text(L10n.screenChangeServerTitle)
                .font(.compound.headingMDBold)
                .multilineTextAlignment(.center)
                .foregroundColor(.compound.textPrimary)
            
            Text(L10n.screenChangeServerSubtitle)
                .font(.compound.bodyMD)
                .multilineTextAlignment(.center)
                .foregroundColor(.compound.textSecondary)
        }
        .padding(.horizontal, 16)
    }
    
    /// The text field and confirm button where the user enters a server URL.
    var serverForm: some View {
        VStack(alignment: .leading, spacing: 24) {
            TextField(L10n.commonServerUrl, text: $context.homeserverAddress)
                .textFieldStyle(.element(labelText: Text(L10n.screenChangeServerFormHeader),
                                         state: context.viewState.isShowingFooterError ? .error : .default,
                                         accessibilityIdentifier: A11yIdentifiers.changeServerScreen.server))
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: context.homeserverAddress) { context.send(viewAction: .clearFooterError) }
                .submitLabel(.done)
                .onSubmit(submit)
            
            Button(action: submit) {
                Text(L10n.actionContinue)
            }
            .buttonStyle(.compound(.primary))
            .disabled(context.viewState.hasValidationError)
            .accessibilityIdentifier(A11yIdentifiers.changeServerScreen.continue)
        }
    }
    
    /// Promotional section for hosted server services
    var hostedServerPromo: some View {
        VStack(spacing: 24) {
            // Divider with "or" text
            HStack(spacing: 0) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.compound.borderInteractiveSecondary)
                
                Text("or")
                    .font(.compound.bodySM)
                    .foregroundColor(.compound.textSecondary)
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.compound.borderInteractiveSecondary)
            }
            
            // Promotional content
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Get a Professional Hosted Server")
                        .font(.compound.headingSMSemibold)
                        .foregroundColor(.compound.textPrimary)
                    
                    Text("Skip the setup, enjoy enterprise-grade reliability")
                        .font(.compound.bodySM)
                        .foregroundColor(.compound.textSecondary)
                    
                    Spacer()
                }
                
                // Key benefits
                VStack(alignment: .leading, spacing: 8) {
                    PromoBenefitRow(icon: "clock.arrow.circlepath", text: "99.9% uptime guarantee with 24/7 monitoring")
                    PromoBenefitRow(icon: "archivebox", text: "Daily data backups")
                    PromoBenefitRow(icon: "globe", text: "Global server locations")
                    PromoBenefitRow(icon: "star.fill", text: "Trusted by 500+ businesses worldwide")
                    
                    Spacer()
                }
                
                // CTA button
                Button(action: { showingHostedServerSheet = true }, label: {
                    Text("Explore Hosting Plans")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.compound(.primary))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.compound.bgCanvasDefault)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.compound.borderInteractiveSecondary, lineWidth: 1)
                    )
            )
        }
    }
    
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button { context.send(viewAction: .dismiss) } label: {
                Text(L10n.actionCancel)
            }
            .accessibilityIdentifier(A11yIdentifiers.changeServerScreen.dismiss)
        }
    }
    
    /// Sends the `confirm` view action so long as the text field input is valid.
    func submit() {
        guard !context.viewState.hasValidationError else { return }
        context.send(viewAction: .confirm)
    }
}

/// Individual benefit row for the promotional section
struct PromoBenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.compound.iconAccentTertiary)
                .font(.body)
                .frame(width: 20)
            
            Text(text)
                .font(.compound.bodySM)
                .foregroundColor(.compound.textSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Previews

struct ServerSelection_Previews: PreviewProvider, TestablePreview {
    static let matrixViewModel = makeViewModel(for: "https://matrix.org")
    static let emptyViewModel = makeViewModel(for: "")
    static let invalidViewModel = makeViewModel(for: "thisisbad")
    
    static var previews: some View {
        NavigationStack {
            ServerSelectionScreen(context: matrixViewModel.context)
        }
        
        NavigationStack {
            ServerSelectionScreen(context: emptyViewModel.context)
        }
        
        NavigationStack {
            ServerSelectionScreen(context: invalidViewModel.context)
        }
        .snapshotPreferences(expect: invalidViewModel.context.observe(\.viewState.hasValidationError))
    }
    
    static func makeViewModel(for homeserverAddress: String) -> ServerSelectionScreenViewModel {
        let authenticationService = AuthenticationService.mock
        
        let viewModel = ServerSelectionScreenViewModel(authenticationService: authenticationService,
                                                       authenticationFlow: .login,
                                                       appSettings: ServiceLocator.shared.settings,
                                                       userIndicatorController: UserIndicatorControllerMock())
        viewModel.context.homeserverAddress = homeserverAddress
        if homeserverAddress == "thisisbad" {
            viewModel.context.send(viewAction: .confirm)
        }
        return viewModel
    }
}
