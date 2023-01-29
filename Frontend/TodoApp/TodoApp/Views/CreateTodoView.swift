//
//  CreateTodoView.swift
//  TodoApp
//
//  Created by Neal Archival on 1/20/23.
//

import SwiftUI

struct CreateItemView: View {
    @Binding var title: String // Required parameter
    @Binding var todoLists: [TodoList] // Require parameter
    @State private var selectedList: UInt64 = 0
    
    @StateObject private var viewModel = TodoViewModel()
    
    @State private var dismissAlertShown: Bool = false
    
    @State private var addMenuOpened: Bool = false
    @State private var priorityMenuOpened: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var session: Session
    
    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea([.all])
            VStack {
                titleTextBox()
                descriptionTextBox()
                HStack(spacing: 20) {
                    listSelectionMenu()
                    prioritySelectionMenu()
                } // HStack
                .font(.system(size: 20))
                .padding([.top])
                formButtons()
                Spacer()
            } // VStack
            .padding([.leading, .trailing])
            .alert(viewModel.errorMessage, isPresented: $viewModel.errorAlertShown) {
                Button("Ok", role: .cancel) {}
            }
            .alert("Do you want to exit? Changes will not be saved", isPresented: $dismissAlertShown) {
                Button("Cancel", role: .cancel) {}
                Button("Exit", role: .destructive) { dismiss() }
            }
        } // ZStack
        .onChange(of: viewModel.createComplete) { _ in
            if viewModel.createComplete {
                dismiss()
            }
        }
        .onTapGesture {
            // We need to add this gesture so when the user clicks outside the menu to close, the state changes (for arrow opening)
            if addMenuOpened {
                addMenuOpened.toggle()
            }
            if priorityMenuOpened {
                priorityMenuOpened.toggle()
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
    
    // MARK: titleTextBox
    @ViewBuilder
    private func titleTextBox() -> some View {
        VStack {
            topLabel("Title")
            TextField("Enter title", text: $title)
                .frame(height: 50)
                .padding([.leading, .trailing])
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
        }
    }
    
    // MARK: descriptionTextBox
    @ViewBuilder
    private func descriptionTextBox() -> some View {
        VStack {
            topLabel("Description")
            TextEditor(text: $viewModel.description)
                .frame(height: 100)
                .padding([.leading, .trailing], 5)
                .scrollContentBackground(.hidden) // Hides the background so we can set a background color to the component
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
        } // VStack
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Create Todo")
    }
    
    // MARK: prioritySelectionMenu
    @ViewBuilder
    private func prioritySelectionMenu() -> some View {
        Menu {
            Group {
                Button(action: {
                    priorityMenuOpened.toggle()
                    viewModel.priority = 0
                }) {
                    if viewModel.priority == 0 {
                        Label("Low", systemImage: "checkmark")
                    } else {
                        Text("Low")
                    }
                } // Button
                Button(action: {
                    priorityMenuOpened.toggle()
                    viewModel.priority = 1
                }) {
                    if viewModel.priority == 1 {
                        Label("Medium", systemImage: "checkmark")
                    } else {
                        Text("Medium")
                    }
                } // Button
                Button(action: {
                    priorityMenuOpened.toggle()
                    viewModel.priority = 2
                }) {
                    if viewModel.priority == 2 {
                        Label("High", systemImage: "checkmark")
                    } else {
                        Text("High")
                    }
                } // Button
            }
        } label: {
            HStack {
                Text("Priority")
                    .font(.system(size: 18, weight: .medium))
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(priorityMenuOpened ? 0 : -90))
                    .scaleEffect(priorityMenuOpened ? 1 : 1)
            } // HStack
            .foregroundColor(Color.black.opacity(0.8))
            .padding([.leading, .trailing])
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .onTapGesture {
            withAnimation {
                priorityMenuOpened.toggle()
            }
        }
    } //
    
    // MARK: listSelectionMenu
    @ViewBuilder
    private func listSelectionMenu() -> some View {
        VStack {
            Menu {
                Button(action: {
                    viewModel.listID = nil
                    addMenuOpened.toggle()
                }) {
                    if viewModel.listID == nil {
                        Label("None", systemImage: "checkmark")
                    } else {
                        Text("None")
                    }
                } // Button - none
                ForEach(todoLists, id: \.id) { todoList in
                    if todoList.id == viewModel.listID {
                        Button(action: {
                            addMenuOpened.toggle()
                        }) {
                            Label("\(todoList.name)", systemImage: "checkmark")
                        }
                    } else {
                        Button(action: {
                            viewModel.listID = todoList.id
                            addMenuOpened.toggle()
                        }) {
                            Text("\(todoList.name)")
                        }
                    }
                } // ForEach
            } label: {
                HStack {
                    Text("Add To List")
                        .font(.system(size: 18, weight: .medium))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(addMenuOpened ? 0 : -90))
                        .scaleEffect(addMenuOpened ? 1 : 1)
                }
                .foregroundColor(Color.black.opacity(0.8))
                .padding([.leading, .trailing])
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
            }
            .onTapGesture {
                // If the user clicks outside of the menu, we need to disable it
                withAnimation() {
                    addMenuOpened.toggle()
                }
            }
        } // VStack
    }
    
    // MARK: toggleComplete
    @ViewBuilder
    private func toggleComplete() -> some View {
        VStack {
            
        }
    }
    
    // MARK: formButtons
    @ViewBuilder
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
            Button(action: createTodoItem) {
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
    
    private func createTodoItem() {
        viewModel.title = title // Set the view model title to the Binding title since the state is shared with the preceding view
        title = "" // Reset
        viewModel.createTodo(token: session.token)
    }
}

struct CreateItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        CreateItemView(title: .constant(""), todoLists: .constant([TodoList(id: 2), TodoList(id: 1)]))
            .environmentObject(Session(customToken: "abcd"))
    }
}
