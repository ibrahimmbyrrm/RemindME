//
//  TextViewContentView.swift
//  Today
//
//  Created by İbrahim Bayram on 8.01.2024.
//

import UIKit

class TextViewContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration {
        func updated(for state: UIConfigurationState) -> TextViewContentView.Configuration {
            return self
        }
        
        var text: String? = ""
        var onChange : (String) -> Void = { _ in}
        
        func makeContentView() -> UIView & UIContentView {
            return TextViewContentView(self)
        }
    }
    
    
    let textView = UITextView()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addPinnedSubviews(textView, height: 200)
        textView.backgroundColor = nil
        textView.delegate = self
        textView.font = .preferredFont(forTextStyle: .body)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textView.text = configuration.text
    }
}

extension TextViewContentView : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let configuration = configuration as? Configuration else { return }
        configuration.onChange(textView.text)
    }
}


extension UICollectionViewListCell {
    func textViewConfiguration() -> TextViewContentView.Configuration {
        TextViewContentView.Configuration()
    }
}
