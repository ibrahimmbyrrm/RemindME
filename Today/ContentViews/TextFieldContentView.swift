//
//  TextFieldContentView.swift
//  Today
//
//  Created by İbrahim Bayram on 8.01.2024.
//

import UIKit

class TextFieldContentView : UIView,UIContentView {
    
    struct Configuration : UIContentConfiguration {
        func updated(for state: UIConfigurationState) -> TextFieldContentView.Configuration {
            return self
        }
        
        var text : String? = ""
        var onChange : (String) -> Void = { _ in }
        
        func makeContentView() -> UIView & UIContentView {
            return TextFieldContentView(self)
        }

        
        
    }
    
    let textField = UITextField()
    var configuration : UIContentConfiguration{
        didSet {
            configure(configuration: configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration : UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        textField.addTarget(self, action: #selector(didChange(_ :)), for: .editingChanged)
        addPinnedSubviews(textField, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        textField.clearButtonMode = .whileEditing
    }
    
    func configure(configuration : UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textField.text = configuration.text
    }
    
    @objc func didChange(_ sender : UITextField) {
        guard let configuration = configuration as? Configuration else { return }
        configuration.onChange(textField.text ?? "")
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
}
