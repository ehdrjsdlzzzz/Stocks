import Foundation

class Stock {
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
}
