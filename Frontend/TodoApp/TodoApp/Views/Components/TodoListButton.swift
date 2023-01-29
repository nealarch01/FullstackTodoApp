//
//  TodoListButton.swift
//  TodoApp
//
//  Created by Neal Archival on 1/15/23.
//

import SwiftUI

struct TodoListButton: View {
    let todoList: TodoList
    let editView: AnyView
    let deleteAction: () -> Void
    
    @State private var deleteAlertShown: Bool = false
    
    var body: some View {
        Button(action: {}) {
            VStack {
                HStack {
                    Circle()
                        .stroke(Color(hexString: todoList.color), lineWidth: 4)
                        // .fill(Color(hexString: todoList.color))
                        .frame(width: 15, height: 15)
                    Text("\(todoList.name)")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.black)
                } // HStack
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
                .padding([.leading, .trailing], 5)
            } // VStack
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .contextMenu {
                longPressMenu()
            }
        } // Button
        .alert("Are you sure you want to delete this list. Todo items will not be deleted but moved", isPresented: $deleteAlertShown) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAction()
            }
        }
    }
    
    @ViewBuilder
    private func longPressMenu() -> some View {
        editView
        Button(action: {
            deleteAlertShown.toggle()
        }) {
            Label("Delete", systemImage: "minus.circle")
        } // Button
    }
}

struct TodoListButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea([.all])
            TodoListButton(
                todoList: TodoList(id: 1),
                editView: AnyView(EmptyView()),
                deleteAction: {}
            )
        } // ZStack
    }
}
