//
//  SecuredTextInput.swift
//  TodoApp
//
//  Created by Neal Archival on 1/8/23.
//

import SwiftUI

struct SecuredTextInput: View {
    @Binding var input: String
    let placeholder: String
    @State private var secured: Bool = true
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    if !secured {
                        TextField(placeholder, text: $input)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    } else {
                        SecureField(placeholder, text: $input)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                } // VStack
                .font(.system(size: 20, weight: .medium))
                .padding([.leading])
                .frame(width: geometry.size.width * 0.8, height: 60)
                
                Button(action: toggleSecured) {
                    Image(systemName: secured ? "eye" : "eye.slash")
                        .font(.system(size: 22))
                        .foregroundColor(Color.black)
                        .frame(width: geometry.size.width * 0.1, height: 60)
                }
                .padding([.trailing], 4)
                
            } // HStack
            .background(Color.gray.opacity(0.35))
            .cornerRadius(12)
            .frame(width: geometry.size.width)
        } // GeometryReader
        .frame(height: 60)
    }
    
    private func toggleSecured() -> Void {
        secured.toggle()
    }
}

struct SecuredTextInput_Previews: PreviewProvider {
    static var previews: some View {
        SecuredTextInput(input: .constant("abcdefghijklmnopqrstuvwxyzabcdd"), placeholder: "Enter password")
    }
}
