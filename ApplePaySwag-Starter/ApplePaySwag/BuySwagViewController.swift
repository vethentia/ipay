//
//  DetailViewController.swift
//  ApplePaySwag
//
//  Created by Erik.Kerber on 10/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

import PassKit

@available(iOS 9.0, *)

extension BuySwagViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    // 
    // User authorization to complete the purchase.
    //
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        completion(PKPaymentAuthorizationStatus.success)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingAddress address: ABRecord, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        
        completion(PKPaymentAuthorizationStatus.success, [], [])
    }
    
    //
    // Payment request completed for processing.
    //
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}

class BuySwagViewController: UIViewController {

    //
    // BuySwagViewController's Properties
    //
    @IBOutlet weak var swagPriceLabel: UILabel!
    @IBOutlet weak var swagTitleLabel: UILabel!
    @IBOutlet weak var swagImage: UIImageView!
    @IBOutlet weak var applePayButton: UIButton!
    
    //
    // Populating PKPaymentRequest
    //
    let SupportedPaymentNetworks = [PKPaymentNetwork.amex,
                                    PKPaymentNetwork.discover,
                                    PKPaymentNetwork.masterCard,
                                    PKPaymentNetwork.visa]  // Supported credit card payment network
    
    let ApplePaySwagMerchantID = "merchant.com.abanh.ApplePay"  // Created in apple development website
    
    var swag: Swag! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {

        if (!self.isViewLoaded) {
            return
        }
        
        self.title = swag.title
        self.swagPriceLabel.text = "$" + swag.priceString
        self.swagImage.image = swag.image
        self.swagTitleLabel.text = swag.description
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.configureView()  // above
        
        // Deteremine if Apple Pay Button should be hidden or not
        applePayButton.isHidden = !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: SupportedPaymentNetworks)
    }
 
    func createShippingAddressFromRef(_ address: ABRecord!) -> Address {
        
        var shippingAddress: Address = Address()
        
        shippingAddress.FirstName = ABRecordCopyValue(address, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
        shippingAddress.LastName = ABRecordCopyValue(address, kABPersonLastNameProperty)?.takeRetainedValue() as? String
        
        
        return shippingAddress
    }
    
    @IBAction func purchase(_ sender: UIButton) {
        
        // Create payment request object
        let request = PKPaymentRequest()
        
        // Merchant ID & Info
        request.merchantIdentifier = ApplePaySwagMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: swag.title, amount: swag.price),
            PKPaymentSummaryItem(label: "Razeware", amount: swag.price)]
        
        // Add summary items & shipping cost
        var summaryItems = [PKPaymentSummaryItem]()
        
        summaryItems.append(PKPaymentSummaryItem(label: swag.title, amount: swag.price))
        if (swag.swagType == .delivered) {
            
            summaryItems.append(PKPaymentSummaryItem(label: "Shipping", amount: swag.shippingPrice))
        }
        
        summaryItems.append(PKPaymentSummaryItem(label: "Razeware", amount: swag.total()))
        
        request.paymentSummaryItems = summaryItems
        
        request.requiredShippingAddressFields = PKAddressField.all

        switch(swag.swagType) {
        
            case SwagType.delivered:
                //request.requiredShippingAddressFields = PKAddressField.PostalAddress | PKAddressField.Phone
                request.requiredShippingAddressFields = PKAddressField.postalAddress
            
            case SwagType.electronic:
                request.requiredShippingAddressFields = PKAddressField.email
        }
        
        // Billing? TBD?
            
        // Contact Info? TBD?
        
        // Create payment authorization view controller for the above payment request
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController.delegate = self
        
        // Prompt user w/ above in its main view controller context
        self.present(applePayController, animated: true, completion: nil)
    }
}

