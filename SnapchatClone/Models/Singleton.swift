
import Foundation

class UserSingleton{
    
    static let sharedInstance = UserSingleton()
    
    var email = ""
    var username = ""
    
    
    private init(){
        
    }
}
