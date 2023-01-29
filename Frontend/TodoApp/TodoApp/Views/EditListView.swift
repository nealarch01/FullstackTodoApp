//
//  EditListView.swift
//  TodoApp
//
//  Created by Neal Archival on 1/28/23.
//

import SwiftUI

struct EditListView: View {
    var todoList: TodoList
    @StateObject private var viewModel = ListViewModel()
    
    @State private var selectedColor: Color = Color(hexString: "#f1f1f1")
    
    @State private var dismissAlertShown: Bool = false
    @State private var deleteAlertShown: Bool = false
    
    @EnvironmentObject var session: Session
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea([.all])
            VStack {
                nameTextBox()
                ColorPicker("Update Color", selection: $selectedColor, supportsOpacity: false)
                    .padding([.top])
                formButtons()
                Spacer()
            }
            .padding([.leading, .trailing])
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    deleteAlertShown.toggle()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(Color.red)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedColor) { updatedColor in
            viewModel.color = selectedColor.getHexCode() ?? "#f1f1f1"
        }
        .alert("Are you sure you want to exist. Changes will not be saved", isPresented: $dismissAlertShown) {
            Button("Cancel", role: .cancel) {}
            Button("Exit", role: .destructive) {
                dismiss()
            }
        }
        .alert("Are you sure you want to delete this list. Your todos will not be removed", isPresented: $deleteAlertShown) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteList(listID: todoList.id, token: session.token)
            }
        }
        .alert(viewModel.errorMessage, isPresented: $viewModel.errorAlertShown) {
            Button("Ok", role: .cancel) {}
        }
        .onChange(of: viewModel.updateComplete) { newState in
            if newState {
                dismiss()
            }
        }
        .onAppear {
            viewModel.name = todoList.name
            viewModel.color = todoList.color
            selectedColor = Color(hexString: todoList.color)
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
        VStack {
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
                    viewModel.updateList(listID: todoList.id, token: session.token)
                }) {
                    Text("Update")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(width: 150, height: 60)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                } // Button - Create
                .padding([.top, .bottom])
            } // HStack - Cancel and Create Buttons
        } // VStack
    }
}

struct EditListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditListView(todoList: TodoList(id: 2))
                .environmentObject(Session(customToken: "abcd"))
        }
    }
}
