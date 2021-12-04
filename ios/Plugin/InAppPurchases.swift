import Foundation
import SwiftyStoreKit
import StoreKit

@objc public class InAppPurchases: NSObject {
    
    private var purchase: [Purchase] = []
    private var purchaseDetails: PurchaseDetails?
    
    public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    public func completeTransactions(_ atomically: Bool, completion: @escaping ([Purchase]) -> Void) {
        SwiftyStoreKit.completeTransactions(atomically: atomically) { purchases in
            self.purchase = purchases
            completion(purchases)
        }
    }
    
    public func purchaseProduct(productId: String, quantity: Int, atomically: Bool, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false, completion: @escaping (PurchaseResult) -> Void) {
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
        var paymentTransaction: PaymentTransaction? = purchaseDetails?.transaction.transactionIdentifier == transactionIdentifier ? purchaseDetails?.transaction : nil
        if paymentTransaction == nil {
            paymentTransaction = purchase.first(where: {$0.transaction.transactionIdentifier == transactionIdentifier})?.transaction
        }
        guard let paymentTransaction = paymentTransaction else {
            throw NSError(domain: "finishTransaction", code: 404, userInfo: ["message" : "purchaseDetails of current transaction doesn't match transactionIdentifier \(transactionIdentifier)"])
        }
        SwiftyStoreKit.finishTransaction(paymentTransaction)
    }
    
    func fetchReceipt(forceRefresh: Bool, completion: @escaping (FetchReceiptResult) -> Void) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: forceRefresh, completion: completion)
    }
    
}
