//
//  EditTodoView.swift
//  TodoApp
//
//  Created by Neal Archival on 1/22/23.
//

import SwiftUI

struct EditTodoView: View {
    var todoItem: Todo
    var todoLists: [TodoList]
    
    @StateObject private var viewModel = TodoViewModel()
    @State private var dismissAlertShown: Bool = false
    @State private var deleteAlertShown: Bool = false
    
    @State private var addMenuOpened: Bool = false
    @State private var priorityMenuOpened: Bool = false
    
    @EnvironmentObject var session: Session
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea([.all])
            VStack {
                titleTextBox()
                descriptionTextBox()
                HStack {
                    listSelectionMenu()
                    prioritySelectionMenu()
                } // HStack
                .padding([.top], 12)
                toggleComplete()
                    .padding([.top], 18)
                formButtons()
                Spacer()
            } // VStack
            .padding([.leading, .trailing])
        } // ZStack
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
        .onAppear {
            viewModel.title = todoItem.title
            viewModel.description = todoItem.description ?? ""
            viewModel.priority = todoItem.priority
            viewModel.listID = todoItem.listID
        }
        .alert("Do you want to exit? Changes will not be saved", isPresented: $dismissAlertShown) {
            Button("Cancel", role: .cancel) {}
            Button("Exit", role: .destructive) { dismiss() }
        }
        .alert("\(viewModel.errorMessage)", isPresented: $viewModel.errorAlertShown) {
            Button("Ok", role: .cancel) {}
        }
        .alert("Are you sure you wanto to delete", isPresented: $deleteAlertShown) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteTodo(todoID: todoItem.id, token: session.token)
            }
        }
        .onChange(of: viewModel.updateComplete) { _ in
            if viewModel.updateComplete {
                dismiss()
            }
        }
        .onTapGesture {
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
    private func titleTextBox() -> some View {
        VStack {
            topLabel("Title")
            TextField("Enter title", text: $viewModel.title)
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
        .navigationTitle("Edit Todo")
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
                }
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
                }
            } label: {
                HStack {
                    Text("Move To List")
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
                withAnimation() {
                    addMenuOpened.toggle()
                }
            }
        } // VStack
    }
    
    // MARK: toggleComplete
    @ViewBuilder
    private func toggleComplete() -> some View {
        ZStack {
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.complete = false
                }) {
                    if !viewModel.complete {
                        Text("Incomplete")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.white)
                            .frame(width: 150, height: 60)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    } else {
                        Text("Incomplete")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.blue)
                            .frame(width: 150, height: 60)
                            .background(Color.offWhite)
                            .cornerRadius(12)
                    }
                } // Button
                Button(action: {
                    viewModel.complete = true
                }) {
                    if viewModel.complete {
                        Text("Complete")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.white)
                            .frame(width: 150, height: 60)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    } else {
                        Text("Complete")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.blue)
                            .frame(width: 150, height: 60)
                            .background(Color.offWhite)
                            .cornerRadius(12)
                    }
                } // Button
            } // HStack
        } // ZStack
    }
    
    // MARK: formButtons
    @ViewBuilder
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
                    viewModel.updateTodo(itemID: todoItem.id, token: session.token)
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

struct EditTodoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditTodoView(
                todoItem: Todo(id: 1),
                todoLists: [TodoList(id: 1), TodoList(id: 2)]
            )
            .environmentObject(Session(customToken: "abcd"))
        }
    }
}
