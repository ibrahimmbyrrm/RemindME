//
//  DatePickerContentView.swift
//  Today
//
//  Created by İbrahim Bayram on 8.01.2024.
//

import UIKit

class DatePickerContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration {
        func updated(for state: UIConfigurationState) -> DatePickerContentView.Configuration {
            return self
        }
        
        var date = Date.now
        var onChange : (Date) -> Void = { _ in }


        func makeContentView() -> UIView & UIContentView {
            return DatePickerContentView(self)
        }
    }


    let datePicker = UIDatePicker()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }


    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        datePicker.addTarget(self, action: #selector(dateDidPick(_ :)), for: .valueChanged)
        addPinnedSubviews(datePicker)
        datePicker.preferredDatePickerStyle = .inline
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        datePicker.date = configuration.date
    }
    
    @objc func dateDidPick(_ sender : UIDatePicker) {
        guard let configuration = configuration as? Configuration else { return }
        configuration.onChange(sender.date)
    }
}


extension UICollectionViewListCell {
    func datePickerConfiguration() -> DatePickerContentView.Configuration {
        DatePickerContentView.Configuration()
    }
}
