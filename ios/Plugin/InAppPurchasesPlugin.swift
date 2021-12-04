import Foundation
import Capacitor
import StoreKit
import SwiftyStoreKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(InAppPurchasesPlugin)
public class InAppPurchasesPlugin: CAPPlugin {
    private let implementation = InAppPurchases()
    
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    @objc func completeTransactions(_ call: CAPPluginCall) {
        let atomically = call.getBool("atomically") ?? false
        implementation.completeTransactions(atomically) { purchases in
            var purchasesArray: [PluginCallResultData] = []
            for purchase in purchases {
                purchasesArray.append([
                    "productId": purchase.productId,
                    "quantity": purchase.quantity,
                    "transaction": [
                        "transactionDate": (purchase.transaction.transactionDate?.timeIntervalSince1970 ?? 0) * 1000,
                        "transactionState": purchase.transaction.transactionState.stringState,
                        "transactionIdentifier": purchase.transaction.transactionIdentifier as Any
                    ],
                    "paymentTransaction": [
                        "transactionDate": (purchase.transaction.transactionDate?.timeIntervalSince1970 ?? 0) * 1000,
                        "transactionState": purchase.transaction.transactionState.stringState,
                        "transactionIdentifier": purchase.transaction.transactionIdentifier as Any
                    ],
                    "needsFinishTransaction": purchase.needsFinishTransaction
                ])
            }
            call.resolve([
                "purchases": purchasesArray
            ])
        }
    }
    
    @objc func purchaseProduct(_ call: CAPPluginCall) {
        let productId = call.getString("productId") ?? ""
        let quantity = call.getInt("quantity") ?? 1
        let atomically = call.getBool("atomically") ?? false
        let applicationUsername = call.getString("applicationUsername") ?? ""
        let simulatesAskToBuyInSandbox = call.getBool("simulatesAskToBuyInSandbox") ?? false
        implementation.purchaseProduct(productId: productId, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox) { purchaseResult in
            
            switch purchaseResult {
            case .success(let product):
                call.resolve(
                    [
                        "productId": product.productId,
                        "quantity": product.quantity,
                        "transaction": [
                            "transactionDate": (product.transaction.transactionDate?.timeIntervalSince1970 ?? 0) * 1000,
                            "transactionState": product.transaction.transactionState.stringState,
                            "transactionIdentifier": product.transaction.transactionIdentifier as Any
                        ],
                        "paymentTransaction": [
                            "transactionDate": (product.transaction.transactionDate?.timeIntervalSince1970 ?? 0) * 1000,
                            "transactionState": product.transaction.transactionState.stringState,
                            "transactionIdentifier": product.transaction.transactionIdentifier as Any
                        ],
                        "needsFinishTransaction": product.needsFinishTransaction
                    ]
                )
    
            case .error(let error):
                switch error.code {
                case .unknown: call.reject("Unknown error. Please contact support", error.code.rawValue.description, error)
                case .clientInvalid: call.reject("Not allowed to make the payment", error.code.rawValue.description, error)
                case .paymentCancelled: call.reject("Payment cancelled", error.code.rawValue.description, error)
                case .paymentInvalid: call.reject("The purchase identifier was invalid", error.code.rawValue.description, error)
                case .paymentNotAllowed: call.reject("The device is not allowed to make the payment", error.code.rawValue.description, error)
                case .storeProductNotAvailable: call.reject("The product is not available in the current storefront", error.code.rawValue.description, error)
                case .cloudServicePermissionDenied: call.reject("Access to cloud service information is not allowed", error.code.rawValue.description, error)
                case .cloudServiceNetworkConnectionFailed: call.reject("Could not connect to the network", error.code.rawValue.description, error)
                case .cloudServiceRevoked: call.reject("User has revoked permission to use this cloud service", error.code.rawValue.description, error)
                default: call.reject((error as NSError).localizedDescription, error.code.rawValue.description, error)
                }
            }
            
        }
    }
    
    @objc func finishTransaction(_ call: CAPPluginCall) {
        let transactionIdentifier = call.getString("transactionIdentifier") ?? ""
        do {
            try implementation.finishTransaction(transactionIdentifier)
            call.resolve()
        } catch let error as NSError {
            call.reject(error.userInfo["message"] as? String ?? "Unknown error", error.code.description, error)
        }
    }
    
    @objc func fetchReceipt(_ call: CAPPluginCall) {
        let forceRefresh = call.getBool("forceRefresh") ?? false
        implementation.fetchReceipt(forceRefresh: forceRefresh) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
                call.resolve(["receiptData": encryptedReceipt])
            case .error(let error):
                call.reject("Fetch receipt failed: \(error.localizedDescription)")
            }
        }
    }
}

private extension SKPaymentTransactionState {
    
    var stringState: String {
        switch self {
        case .purchasing:
            return "purchasing"
        case .purchased:
            return "purchased"
        case .failed:
            return "failed"
        case .restored:
            return "restored"
        case .deferred:
            return "deferred"
        @unknown default:
            return "unknown"
        }
    }
}
