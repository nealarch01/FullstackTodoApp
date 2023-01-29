//
//  CreateListView.swift
//  TodoApp
//
//  Created by Neal Archival on 1/26/23.
//

import SwiftUI

struct CreateListView: View {
    @StateObject private var viewModel = ListViewModel()
    
    @State private var selectedColor = Color(hexString: "#f1f1f1")
    @State private var dismissAlertShown: Bool = false
    
    @Environment (\.dismiss) var dismiss
    
    @EnvironmentObject var session: Session
    
    var body: some View {
        VStack {
            nameTextBox()
            ColorPicker("Set list color", selection: $selectedColor, supportsOpacity: false)
                .padding([.top])
            formButtons()
                .padding([.top], 10)
            Spacer()
        } // VStack
        .padding([.leading, .trailing])
        .onChange(of: selectedColor) { newColor in
            viewModel.color = newColor.getHexCode() ?? "#f1f1f1"
        } // VStack onChange
        .alert("Do you want to exit? Changes will not be saved", isPresented: $dismissAlertShown) {
            Button("Cancel", role: .cancel) {}
            Button("Exit", role: .destructive) { dismiss() }
        }
        .alert(viewModel.errorMessage, isPresented: $viewModel.errorAlertShown) {
            Button("Ok", role: .cancel) {}
        }
        .onChange(of: viewModel.createComplete) { updatedState in
            if updatedState {
                dismiss()
            }
        }
        
    }
    
    // MARK: topLabel
    @ViewBuilder
    private func topLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 22, weight: .medium))
            Spacer()
        }
    }
    
    // MARK: nameTextBox
    private func nameTextBox() -> some View {
        VStack {
            topLabel("Todo List Name")
            TextField("Enter name", text: $viewModel.name)
                .frame(height: 50)
                .padding([.leading, .trailing])
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
        }
    }
    
    
    private func formButtons() -> some View {
        HStack(spacing: 20) {
            Button(action: {
                dismissAlertShown.toggle()
            }) {
                Text("Cancel")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.blue)
                    .frame(width: 150, height: 60)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
            } // Button - Cancel
            Button(action: {
                viewModel.createList(token: session.token)
            }) {
                Text("Create")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.white)
                    .frame(width: 150, height: 60)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 2)
            } // Button - Create
            .padding([.top, .bottom])
        } // HStack - Cancel and Create Buttons
    }
    
    private func viewHex() -> Void {
        print(selectedColor.description)
    }
}

struct CreateListView_Previews: PreviewProvider {
    static var previews: some View {
        CreateListView()
            .environmentObject(Session(customToken: ""))
    }
}
