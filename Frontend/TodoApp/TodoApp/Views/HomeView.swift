//
//  HomeView.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: Session
    private let doubleColumn = [
        GridItem(.adaptive(minimum: 100)),
        GridItem(.adaptive(minimum: 100))
    ]
    
    private let singleColumn = [
        GridItem(.fixed(100))
    ]
    
    @State private var todolists: [TodoList] = [TodoList(id: 1), TodoList(id: 2), TodoList(id: 3)]
    @State private var todoItems: [Todo] = [Todo(id: 1), Todo(id: 2), Todo(id: 3), Todo(id: 4), Todo(id: 5), Todo(id: 6)]
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var showCompleted: Bool = false
    @State private var titleInput: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.offWhite
                    .ignoresSafeArea([.all])
                VStack {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(pinnedViews: [.sectionFooters]) {
                            Section {
                                todoListsView()
                                    .padding([.leading, .trailing])
                                todoItemsView()
                            } // Section
                        } // LazyVStack
                    } // ScrollView
                    .clipped()
                    addItemFooter()
                } // VStack
            } // ZStack
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.offWhite, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileView()) {
                        Text(Image(systemName: "person.crop.circle.fill"))
                            .font(.system(size: 22))
                            .foregroundColor(Color.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Home")
                        .font(.system(size: 20, weight: .medium))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarMenuItems()
                } // ToolbarItem
            } // toolbar
            .onAppear {
                viewModel.fetchUserData(token: session.token)
            }
        } // NavigationStack
    }
    
    // MARK: toolbarMenuItems
    @ViewBuilder
    private func toolbarMenuItems() -> some View {
        Menu("\(Image(systemName: "ellipsis.circle"))") {
            NavigationLink(destination: CreateListView()) {
                Text("Create List")
            }
            Button(action: {
                viewModel.fetchUserData(token: session.token)
            }) {
                Text("Refresh")
            }
            Button(action: {
               viewModel.sortCompleted()
            }) {
                Text("Sort")
            }
        } // Menu
        .font(.system(size: 20))
    }
    
    // MARK: todoListsView
    @ViewBuilder
    private func todoListsView() -> some View {
        LazyVGrid(columns: viewModel.isListsLoading ? singleColumn : doubleColumn, spacing: 15, pinnedViews: [.sectionHeaders]) {
            Section(header: myListsHeader()) {
                if viewModel.isListsLoading {
                    ProgressView()
                        .frame(width: 50, height: 50)
                } else {
                    ForEach(Array(viewModel.userTodoLists.enumerated()), id: \.offset) { index, element in
                        TodoListButton(
                            todoList: element,
                            editView: AnyView(editListNavigator(list: element)),
                            deleteAction: { viewModel.deleteList(listID: element.id, token: session.token) }
                        )
                    } // ForEach
                }
            } // Section
        } // LazyVGrid
    }
    
    // MARK: todoItemsView
    @ViewBuilder
    private func todoItemsView() -> some View {
        LazyVStack(pinnedViews: [.sectionHeaders]) {
            Section(header: myTodoItemsHeader()) {
                if viewModel.isItemsLoading {
                    ProgressView()
                        .frame(width: 50, height: 50)
                } else {
                    ForEach(Array(viewModel.userTodoItems.enumerated()), id: \.offset) { _, element in
                        if !showCompleted && element.completed {
                        } else {
                            TodoItemButton(
                                todoItem: element,
                                color: viewModel.getItemColor(listID: element.listID),
                                completeAction: { viewModel.toggleCompleted(todoID: element.id, token: session.token) },
                                editView: AnyView(editTodoNavigator(item: element)),
                                deleteAction: { viewModel.deleteTodo(todoID: element.id, token: session.token) }
                            )
                        }
                    } // ForEach
                    .onChange(of: showCompleted) { newState in
                        viewModel.sortCompleted()
                    }
                }
            } // Section
        } // LazyVStack - TodoItems
    }
    
    // MARK: myListsHeader
    @ViewBuilder
    private func myListsHeader() -> some View {
        HStack {
            Text("My Todo Lists")
                .font(.system(size: 36, weight: .bold))
            Spacer()
        }
        .padding([.bottom, .top], 10)
        .background(Color.offWhite)
    }
    
    // MARK: myTodoItemsHeader
    @ViewBuilder
    private func myTodoItemsHeader() -> some View {
        HStack {
            Text("Todo Items")
                .font(.system(size: 36, weight: .bold))
            Spacer()
            Menu("\(Image(systemName: "arrow.up.arrow.down.circle"))") {
                Text("Sort by")
                Button(action: {}) {
                    Label("Priority", systemImage: "exclamationmark.2")
                }
                Button(action: {}) {
                    Label("Due", systemImage: "clock")
                }
                Button(action: {
                    showCompleted.toggle()
                }) {
                    Label {
                        if showCompleted {
                            Text("Hide Completed")
                        } else {
                            Text("Show Completed")
                        }
                    } icon: {
                        if showCompleted {
                            Image(systemName: "eye.slash")
                        } else {
                            Image(systemName: "eye")
                        }
                    }
                }
            } // Menu
            .font(.system(size: 30))
        }
        .padding([.bottom, .top], 10)
        .padding([.leading, .trailing])
        .background(Color.offWhite)
    }
    
    // MARK: addItemFooter
    @ViewBuilder
    private func addItemFooter() -> some View {
        GeometryReader { geometry in
            HStack {
                TextField("New Item", text: $titleInput)
                    .frame(height: 50)
                    .padding([.leading, .trailing])
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                NavigationLink(destination: CreateItemView(title: $titleInput, todoLists: $viewModel.userTodoLists)) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.white)
                        .padding([.leading, .trailing], 15)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }
            .frame(width: geometry.size.width * 0.9)
            .frame(width: geometry.size.width, height: 60)
            .background(Color.offWhite)
        }
        .frame(height: 60)
    }
    
    // MARK: editTodoNavigator
    // This function will ensure the UI todoItem can be updated after update is complete, also, we don't need to pass TodoList to every item
    @ViewBuilder
    public func editTodoNavigator(item: Todo) -> some View {
        NavigationLink(destination: EditTodoView(todoItem: item, todoLists: viewModel.userTodoLists)) {
            Label("Edit", systemImage: "pencil")
        }
    }
    
    @ViewBuilder
    public func editListNavigator(list: TodoList) -> some View {
        NavigationLink(destination: EditListView(todoList: list)) {
            Label("Edit", systemImage: "pencil")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(Session(customToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNjc0MTg2NzMxLCJleHAiOjE2NzUyMjM1MzF9.CyUCVixEEc1hK8Ijh97z9RjrGnmsKOpdteAvjtawvDY"))
    }
}
