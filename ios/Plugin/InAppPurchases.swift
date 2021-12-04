import Foundation
import SwiftyStoreKit
import StoreKit

@objc public class InAppPurchases: NSObject {
    
    //private var purchase: [Purchase] = []
    private var purchaseDetails: PurchaseDetails?
    
    public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    //
    //    public func completeTransactions(_ atomically: Bool = false) {
    //
    //        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
    //            self.purchase = purchases
    //            for purchase in purchases {
    //                switch purchase.transaction.transactionState {
    //                case .purchased, .restored:
    //
    //                    // TODO add handler
    //                    break
    //                case .failed, .purchasing, .deferred:
    //                    break // do nothing
    //                @unknown default:
    //                    fatalError("Unknown purchase.transaction.transactionState \(purchase.transaction.transactionState)")
    //                }
    //            }
    //        }
    //    }
    
    public func purchaseProduct(productId: String, quantity: Int, atomically: Bool = false, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false, completion: @escaping (PurchaseResult) -> Void) {
        SwiftyStoreKit.purchaseProduct(productId, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox) { [weak self] result in
            switch result {
            case .success(let product):
                self?.purchaseDetails = product
                print("Purchase Success: \(product.productId)")
            case .error(_): break
            }
            completion(result)
        }
    }
    
    public func finishTransaction(_ transactionIdentifier: String) throws {
        guard let purchaseDetails = purchaseDetails, transactionIdentifier == purchaseDetails.transaction.transactionIdentifier else {
            throw NSError(domain: "finishTransaction", code: 404, userInfo: ["message" : "purchaseDetails of current transaction doesn't match transactionIdentifier \(transactionIdentifier)"])
        }
        SwiftyStoreKit.finishTransaction(purchaseDetails.transaction)
    }
    
}
