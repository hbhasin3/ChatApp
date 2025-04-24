//
//  LoadingIndicator.swift
//

import SwiftUI

struct LoadingIndicator: UIViewRepresentable {

    typealias UIViewType = UIActivityIndicatorView

    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<LoadingIndicator>) -> LoadingIndicator.UIViewType {
        let view = UIActivityIndicatorView(style: style)
        view.color = .gray
        return view
    }

    func updateUIView(_ view: LoadingIndicator.UIViewType, context: UIViewRepresentableContext<LoadingIndicator>) {
        view.startAnimating()
    }
    
}

