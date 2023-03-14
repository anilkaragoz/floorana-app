import Foundation

extension Float {
    var priceFormat: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.decimalSeparator = "."
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = ","

        return numberFormatter.string(from: self as NSNumber) ?? ""
    }
}

extension Double {
    var priceFormat: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.decimalSeparator = "."
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = ","

        return numberFormatter.string(from: self as NSNumber) ?? ""
    }
}
