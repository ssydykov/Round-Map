
import Foundation

public struct IAPProducts {
  
    public static let supportOneIAP = "com.strixit.RoundTheWorldPremium"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [IAPProducts.supportOneIAP]
    
    public static let store = IAPHelper(productIds: IAPProducts.productIdentifiers)
    
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
