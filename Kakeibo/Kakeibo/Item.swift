import Foundation
import RealmSwift

class Item: Object{
    
    // 登録日時
    dynamic var created = Date()
    
    // 品名
    dynamic var name: String? = nil
    
    // 金額
    dynamic var price = 0
    
    
}
