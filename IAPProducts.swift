
import Foundation

public struct IAPProducts {
  
    public static let supportOneIAP = "com.joode.unlockBasic"
    public static let myPrice099 = "com.joode.myPrice099"
    public static let myPrice199 = "com.joode.myPrice199"
    public static let myPrice299 = "com.joode.myPrice299"
    public static let myPrice399 = "com.joode.myPrice399"
    public static let myPrice499 = "com.joode.myPrice499"
    public static let myPrice599 = "com.joode.myPrice599"
    public static let myPrice699 = "com.joode.myPrice699"
    public static let myPrice799 = "com.joode.myPrice799"
    public static let myPrice899 = "com.joode.myPrice899"
    public static let myPrice999 = "com.joode.myPrice999"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [IAPProducts.supportOneIAP]
    fileprivate static let pwywProductIdentifiers: Set<ProductIdentifier> = [IAPProducts.myPrice099,IAPProducts.myPrice199,IAPProducts.myPrice299,IAPProducts.myPrice399,IAPProducts.myPrice499,IAPProducts.myPrice599,IAPProducts.myPrice699,IAPProducts.myPrice799,IAPProducts.myPrice899,IAPProducts.myPrice999]
    
    public static let store = IAPHelper(productIds: IAPProducts.productIdentifiers)
    public static let pwywStore = IAPHelper(productIds: IAPProducts.pwywProductIdentifiers)
    

}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
