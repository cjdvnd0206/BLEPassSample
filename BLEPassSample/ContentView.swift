//
//  ContentView.swift
//  BLEPassSample
//
//  Created by user on 2022/07/13.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        HStack {
            TextField("번호입력", text: $viewModel.id)
                .frame(width: 200, alignment: .center)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.isSending)
            Button(viewModel.buttonText, action: viewModel.buttonToggle)
                .disabled(viewModel.id.isEmpty)
                .padding()
        }
        .onAppear(perform: viewModel.setupCentralManager)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
