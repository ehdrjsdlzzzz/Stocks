import Foundation

class Formatters {
    static let price: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // Double 타입을 쉼표로 표현하기 위해
        return formatter
    }()
}
class Stock: Codable{
    
    static let didUpdate = Notification.Name(rawValue: "Stock.didUpdate")
    static let didDelete = Notification.Name(rawValue: "Stock.didDelete")
    
    let name: String
    let code: String
    var price: Double
    var isPriceUp: Bool
    var isPriceKeep: Bool
    var priceDiff: Double
    var rateDiff: Double
    var exchange: String?
    var amount: Int
    var groupTitle: String?
    var dayChartImageUrl: URL?
    var monthChartImageUrl: URL?
    var threeMonthsChartImageUrl: URL?
    var yearChartImageUrl: URL?
    var threeYearsChartImageUrl: URL?
    
    init(name: String, code: String, price: Double,
         isPriceUp: Bool, isPriceKeep: Bool, priceDiff: Double,
         rateDiff: Double, exchange: String?, amount: Int = 0) {
        self.name = name
        self.code = code
        self.price = price
        self.isPriceUp = isPriceUp
        self.isPriceKeep = isPriceKeep
        self.priceDiff = priceDiff
        self.rateDiff = rateDiff
        self.exchange = exchange
        self.amount = amount
    }
    
    var value: String {
        return Formatters.price.string(from: NSNumber(value: price * Double(amount))) ?? ""
    }
    
    var priceText: String {
        return Formatters.price.string(from: NSNumber(value: price)) ?? ""
    }
    
    var priceDiffText: String {
        let diffText = Formatters.price.string(from: NSNumber(value: priceDiff)) ?? ""
        
        if isPriceKeep {
            return "0 +0.00%"
        } else if isPriceUp {
            return "▲ \(diffText) +\(rateDiff)%"
        } else {
            return "▼ \(diffText) -\(rateDiff)%"
        }
    }
}
