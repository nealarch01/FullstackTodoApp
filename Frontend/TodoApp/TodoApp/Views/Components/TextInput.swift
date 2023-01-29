//
//  TextInput.swift
//  TodoApp
//
//  Created by Neal Archival on 1/8/23.
//

import SwiftUI

struct TextInput: View {
    @Binding var input: String
    let placeholder: String
    var body: some View {
        GeometryReader { geometry in
            TextField(placeholder, text: $input)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .font(.system(size: 20, weight: .medium))
                .padding([.leading, .trailing])
                .frame(width: geometry.size.width * 0.9, height: 60)
                .background(Color.gray.opacity(0.35))
                .cornerRadius(12)
                .frame(width: geometry.size.width)
        }
        .frame(height: 60)
    }
}

struct TextInput_Previews: PreviewProvider {
    @State var inputStr: String = ""
    static var previews: some View {
        TextInput(input: .constant("abc"), placeholder: "Enter username")
    }
}
