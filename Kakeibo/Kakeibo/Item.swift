import Foundation
import RealmSwift

class Item: Object{
    
    // 登録日時
    dynamic var created = Date()
    
    // 登録年
    dynamic var year = 0;
    
    // 登録月
    dynamic var month = 0;
    
    // 品名
    dynamic var name: String? = nil
    
    // 金額
    dynamic var price = 0
    
    
}
