//
//  ViewController.swift
//  In-App Purchase
//
//  Created by Nilesh Kumar on 12/03/22.
//

import UIKit
import StoreKit

enum productType: String, CaseIterable{
    case removeAds = "com.myApp.removeAds"
    case showAllProducts = "com.myApp.showAllProducts"
    case buyGems = "com.myApp.buyGems"
}


class ViewController: UIViewController {
    
    var model = [SKProduct]()
    
    private let table: UITableView = {
        let table = UITableView()
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        fetchProducts()
        SKPaymentQueue.default().add(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    func fetchProducts(){
        let request = SKProductsRequest(productIdentifiers: Set(productType.allCases.compactMap({$0.rawValue})))
        request.delegate = self
        request.start()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productModel = model[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(productModel.localizedTitle): \(productModel.localizedDescription) - \(productModel.priceLocale.currencySymbol ?? "Rs")\(productModel.price)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let productModel = model[indexPath.row]
        let payment = SKPayment(product: productModel)
        SKPaymentQueue.default().add(payment)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            print("\(response.products)")
            self.model = response.products
            self.table.reloadData()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState{
            case .purchasing:
                print("purchasing")
            case .purchased:
                print("Purchased")
            case .failed:
                print("Failed")
            case .restored:
                print("Restored")
            case .deferred:
                break
            @unknown default:
                break
            }
        })
    }
    
}
