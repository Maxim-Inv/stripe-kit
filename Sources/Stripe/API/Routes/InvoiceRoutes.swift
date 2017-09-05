//
//  InvoiceRoutes.swift
//  Stripe
//
//  Created by Anthony Castelli on 9/4/17.
//
//

import Foundation
import Node
import HTTP

public final class InvoiceRoutes {
    
    let client: StripeClient
    
    init(client: StripeClient) {
        self.client = client
    }
    
    /**
     If you need to invoice your customer outside the regular billing cycle, you can create an invoice that pulls in all 
     pending invoice items, including prorations. The customer’s billing cycle and regular subscription won’t be affected.
     
     Once you create the invoice, Stripe will attempt to collect payment according to your subscriptions settings, 
     though you can choose to pay it right away.
     
     - parameter customer:            The ID of the customer to attach the invoice to
     - parameter subscription:        The ID of the subscription to invoice. If not set, the created invoice will include all 
                                      pending invoice items for the customer. If set, the created invoice will exclude pending 
                                      invoice items that pertain to other subscriptions.
     - parameter fee:                 A fee to charge if you are using connected accounts (Must be in cents)
     - parameter account:             The account to transfer the fee to
     - parameter description:         A description for the invoice
     - parameter metadata:            Aditional metadata info
     - parameter taxPercent:          The percent tax rate applied to the invoice, represented as a decimal number.
     - parameter statementDescriptor: Extra information about a charge for the customer’s credit card statement.
     
     - returns: A StripeRequest<> item which you can then use to convert to the corresponding node
     */
    
    public func create(forCustomer customer: String, subscription: String? = nil, withFee fee: Int? = nil, toAccount account: String? = nil, description: String? = nil, metadata: Node? = nil, taxPercent: Double? = nil, statementDescriptor: String? = nil) throws -> StripeRequest<Invoice> {
        var body = Node([:])
        // Create the headers
        var headers: [HeaderKey : String]?
        if let account = account {
            headers = [
                StripeHeader.Account: account
            ]
            
            if let fee = fee {
                body["application_fee"] = Node(fee)
            }
        }
        
        body["customer"] = Node(customer)
        
        if let subscription = subscription {
            body["subscription"] = Node(subscription)
        }
        
        if let description = description {
            body["description"] = Node(description)
        }
        
        if let taxPercent = taxPercent {
            body["description"] = Node(taxPercent)
        }
        
        if let statementDescriptor = statementDescriptor {
            body["statement_descriptor"] = Node(statementDescriptor)
        }
        
        if let metadata = metadata?.object {
            for (key, value) in metadata {
                body["metadata[\(key)]"] = value
            }
        }
        
        return try StripeRequest(client: self.client, method: .post, route: .invoices, body: Body.data(body.formURLEncoded()), headers: headers)
    }
    
    /**
     Retrieves the invoice with the given ID.
     
     - parameter invoice: The Invoice ID to fetch
     
     - returns: A StripeRequest<> item which you can then use to convert to the corresponding node
    */
    public func fetch(invoice invoiceId: String) throws -> StripeRequest<Invoice> {
        return try StripeRequest(client: self.client, method: .post, route: .invoice(invoiceId), body: nil, headers: nil)
    }
    
    /**
     When retrieving an invoice, you’ll get a lines property containing the total count of line items and the first handful 
     of those items. There is also a URL where you can retrieve the full (paginated) list of line items.
     
     - parameter invoiceId: The Invoice ID to fetch
     - parameter customer:  In the case of upcoming invoices, the customer of the upcoming invoice is required. In other 
                            cases it is ignored.
     - parameter coupon:    For upcoming invoices, preview applying this coupon to the invoice. If a subscription or 
                            subscription_items is provided, the invoice returned will preview updating or creating a 
                            subscription with that coupon. Otherwise, it will preview applying that coupon to the customer 
                            for the next upcoming invoice from among the customer’s subscriptions. Otherwise this parameter 
                            is ignored. This will be unset if you POST an empty value.
     - parameter filter:    Parameters used to filter the results
     
     - returns: A StripeRequest<> item which you can then use to convert to the corresponding node
    */
    
    public func listItems(forInvoice invoiceId: String, customer: String? = nil, coupon: String? = nil, filter: StripeFilter? = nil) throws -> StripeRequest<InvoiceLineGroup> {
        var query = [String : NodeRepresentable]()
        if let data = try filter?.createQuery() {
            query = data
        }
        
        if let customer = customer {
            query["customer"] = customer
        }
        
        if let coupon = coupon {
            query["coupon"] = coupon
        }
        
        return try StripeRequest(client: self.client, method: .get, route: .invoiceLines(invoiceId), query: query, body: nil, headers: nil)
    }
    
}
