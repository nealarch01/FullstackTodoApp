//
//  TodoItemButton.swift
//  TodoApp
//
//  Created by Neal Archival on 1/15/23.
//

import SwiftUI

struct TodoItemButton: View {
    var todoItem: Todo
    let color: String
    var completeAction: () -> Void
    var editView: AnyView
    var deleteAction: () -> Void
    // This binding will be used to determine whether the button was updated
    
    @State private var confirmDeleteAlertShown: Bool = false
    
    @EnvironmentObject var session: Session
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Button(action: {}) {
                        HStack {
                            Circle()
                                .stroke(Color(hexString: color, opacity: 1.0), lineWidth: 4)
                                .frame(width: 15, height: 15)
                            Text("\(todoItem.title)")
                                .font(.system(size: 20, weight: .regular))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(todoItem.completed ? Color.gray : Color.black)
                                .strikethrough(todoItem.completed, pattern: .solid, color: Color.black)
                            Spacer()
                        } // HStack
                    } // Button
                    .padding([.leading])
                    Spacer()
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 1)
                    HStack {
                        Button(action: {
                            withAnimation(.linear) {
                                completeAction()
                            }
                        }) {
                            Text("\(Image(systemName: !todoItem.completed ? "checkmark" : "arrow.uturn.backward"))")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.green)
                                .frame(height: 60)
                                .padding([.leading, .trailing], 12)
                                .background(Color.white)
                        } // Button
                    } // HStack
                } // HStack
                .frame(width: geometry.size.width * 0.9, height: 60)
                .background(Color.white)
                .cornerRadius(12)
                .contextMenu {
                    longPressMenu()
                }
                .frame(width: geometry.size.width) // Centers the view
            } // GeometryReader
            .frame(height: 60)
            .alert("Are you sure you want to delete this item?", isPresented: $confirmDeleteAlertShown) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .destructive) {
                    deleteAction()
                } // Button
            } // alert - confirmDelete
        }
    }
    
    @ViewBuilder
    private func longPressMenu() -> some View {
        Group {
            editView
            Button(role: .destructive, action: {
                confirmDeleteAlertShown.toggle()
            }) {
                Label {
                    Text("Delete")
                } icon: {
                    Image(systemName: "minus.circle")
                } // Label
                .background(Color.red)
            } // Button
        } // Group
    }
}

@ViewBuilder
public func emptyView() -> some View {
    Text("")
}

struct TodoItemButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ZStack {
                Color.offWhite
                    .ignoresSafeArea([.all])
                TodoItemButton(
                    todoItem: Todo(id: 1),
                    color: "#0000ff",
                    completeAction: {},
                    editView: AnyView(EmptyView()),
                    deleteAction: {}
                )
            }
        }
        .environmentObject(Session(customToken: "abcd"))
    }
}
