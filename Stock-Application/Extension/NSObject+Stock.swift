import Foundation

extension NSObject{
    static var reuseableIdentifier: String{
        return String(describing: self)
    }
}
