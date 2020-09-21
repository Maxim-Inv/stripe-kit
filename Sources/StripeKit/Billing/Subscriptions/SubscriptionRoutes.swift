//
//  SubscriptionRoutes.swift
//  Stripe
//
//  Created by Andrew Edwards on 6/9/17.
//
//

import NIO
import NIOHTTP1
import Foundation

public protocol SubscriptionRoutes {
    /// Creates a new subscription on an existing customer.
    ///
    /// - Parameters:
    ///   - customer: The identifier of the customer to subscribe
    ///   - addInvoiceItems: A list of prices and quantities that will generate invoice items appended to the first invoice for this subscription. You may pass up to 10 items.
    ///   - applicationFeePercent: A non-negative decimal between 0 and 100, with at most two decimal places. This represents the percentage of the subscription invoice subtotal that will be transferred to the application owner’s Stripe account. The request must be made with an OAuth key in order to set an application fee percentage. For more information, see the application fees documentation.
    ///   - backdateStartDate: For new subscriptions, a past timestamp to backdate the subscription’s start date to. If set, the first invoice will contain a proration for the timespan between the start date and the current time. Can be combined with trials and the billing cycle anchor.
    ///   - billingCycleAnchor: A future timestamp to anchor the subscription’s [billing cycle](https://stripe.com/docs/subscriptions/billing-cycle). This is used to determine the date of the first full invoice, and, for plans with `month` or `year` intervals, the day of the month for subsequent invoices.
    ///   - billingThresholds: Define thresholds at which an invoice will be sent, and the subscription advanced to a new billing period. Pass an empty string to remove previously-defined thresholds.
    ///   - cancelAt: A timestamp at which the subscription should cancel. If set to a date before the current period ends, this will cause a proration if prorations have been enabled using proration_behavior. If set during a future period, this will always cause a proration for that period.
    ///   - cancelAtPeriodEnd: Boolean indicating whether this subscription should cancel at the end of the current period.
    ///   - collectionMethod: Either `charge_automatically`, or `send_invoice`. When charging automatically, Stripe will attempt to pay this subscription at the end of the cycle using the default source attached to the customer. When sending an invoice, Stripe will email your customer an invoice with payment instructions. Defaults to `charge_automatically`.
    ///   - coupon: The code of the coupon to apply to this subscription. A coupon applied to a subscription will only affect invoices created for that particular subscription. This will be unset if you POST an empty value.
    ///   - daysUntilDue: Number of days a customer has to pay invoices generated by this subscription. Valid only for subscriptions where `billing` is set to `send_invoice`.
    ///   - defaultPaymentMethod: ID of the default payment method for the subscription. It must belong to the customer associated with the subscription. If not set, invoices will use the default payment method in the customer’s invoice settings.
    ///   - defaultSource: ID of the default payment source for the subscription. It must belong to the customer associated with the subscription and be in a chargeable state. If not set, defaults to the customer’s default source.
    ///   - defaultTaxRates: The tax rates that will apply to any subscription item that does not have `tax_rates` set. Invoices created will have their `default_tax_rates` populated from the subscription.
    ///   - items: List of subscription items, each with an attached plan.
    ///   - metadata: A set of key-value pairs that you can attach to a Subscription object. It can be useful for storing additional information about the subscription in a structured format.
    ///   - offSession: Indicates if a customer is on or off-session while an invoice payment is attempted.
    ///   - paymentBehavior: Use `allow_incomplete` to create subscriptions with `status=incomplete` if its first invoice cannot be paid. Creating subscriptions with this status allows you to manage scenarios where additional user actions are needed to pay a subscription’s invoice. For example, SCA regulation may require 3DS authentication to complete payment. See the [SCA Migration Guide](https://stripe.com/docs/billing/migration/strong-customer-authentication) for Billing to learn more. This is the default behavior. Use `error_if_incomplete` if you want Stripe to return an HTTP 402 status code if a subscription’s first invoice cannot be paid. For example, if a payment method requires 3DS authentication due to SCA regulation and further user action is needed, this parameter does not create a subscription and returns an error instead. This was the default behavior for API versions prior to 2019-03-14. See the [changelog](https://stripe.com/docs/upgrades#2019-03-14) to learn more. `pending_if_incomplete` is only used with updates and cannot be passed when creating a subscription.
    ///   - pendingInvoiceItemInterval: Specifies an interval for how often to bill for any pending invoice items. It is analogous to calling [Create an invoice](https://stripe.com/docs/api#create_invoice) for the given subscription at the specified interval.
    ///   - prorationBehavior: Determines how to handle prorations resulting from the `billing_cycle_anchor`. Valid values are `create_prorations` or `none`. Passing `create_prorations` will cause proration invoice items to be created when applicable. Prorations can be disabled by passing `none`. If no value is passed, the default is `create_prorations`.
    ///   - transferData: If specified, the funds from the subscription’s invoices will be transferred to the destination and the ID of the resulting transfers will be found on the resulting charges.
    ///   - trialEnd: Unix timestamp representing the end of the trial period the customer will get before being charged for the first time. This will always overwrite any trials that might apply via a subscribed plan. If set, `trial_end` will override the default trial period of the plan the customer is being subscribed to. The special value now can be provided to end the customer’s trial immediately. Can be at most two years from `billing_cycle_anchor`.
    ///   - trialFromPlan: Indicates if a plan’s `trial_period_days` should be applied to the subscription. Setting `trial_end` per subscription is preferred, and this defaults to false. Setting this flag to true together with `trial_end` is not allowed.
    ///   - trialPeriodDays: Integer representing the number of trial period days before the customer is charged for the first time. This will always overwrite any trials that might apply via a subscribed plan.
    ///   - expand: An array of properties to expand.
    /// - Returns: A `StripeSubscription`.
    func create(customer: String,
                addInvoiceItems: [[String: Any]]?,
                applicationFeePercent: Decimal?,
                backdateStartDate: Date?,
                billingCycleAnchor: Date?,
                billingThresholds: [String: Any]?,
                cancelAt: Date?,
                cancelAtPeriodEnd: Bool?,
                collectionMethod: StripeInvoiceCollectionMethod?,
                coupon: String?,
                daysUntilDue: Int?,
                defaultPaymentMethod: String?,
                defaultSource: String?,
                defaultTaxRates: [String]?,
                items: [[String: Any]],
                metadata: [String: String]?,
                offSession: Bool?,
                paymentBehavior: StripeSubscriptionPaymentBehavior?,
                pendingInvoiceItemInterval: [String: Any]?,
                prorationBehavior: StripeSubscriptionProrationBehavior?,
                transferData: [String: Any]?,
                trialEnd: Any?,
                trialFromPlan: Bool?,
                trialPeriodDays: Int?,
                expand: [String]?) -> EventLoopFuture<StripeSubscription>
    
    /// Retrieves the subscription with the given ID.
    ///
    /// - Parameters:
    ///   - id: ID of the subscription to retrieve.
    ///   - expand: An array of properties to expand.
    /// - Returns: A `StripeSubscription`.
    func retrieve(id: String, expand: [String]?) -> EventLoopFuture<StripeSubscription>
    
    /// Updates an existing subscription to match the specified parameters. When changing plans or quantities, we will optionally prorate the price we charge next month to make up for any price changes. To preview how the proration will be calculated, use the [upcoming invoice](https://stripe.com/docs/api/subscriptions/update#upcoming_invoice) endpoint. /n By default, we prorate subscription changes. For example, if a customer signs up on May 1 for a $100 plan, she'll be billed $100 immediately. If on May 15 she switches to a $200 plan, then on June 1 she'll be billed $250 ($200 for a renewal of her subscription, plus a $50 prorating adjustment for half of the previous month's $100 difference). /n Similarly, a downgrade will generate a credit to be applied to the next invoice. We also prorate when you make quantity changes. Switching plans does not normally change the billing date or generate an immediate charge. The exception is when you're switching between different intervals (e.g., monthly to yearly): in this case, we apply a credit for the time unused on the old plan, and charge for the new plan starting right away, resetting the billing date. (However, note that if we charge for the new plan and that payment fails, the plan change will not go into effect). /n If you'd like to charge for an upgrade immediately, just pass `prorate` as `true` (as usual), and then [invoice the customer](https://stripe.com/docs/api/subscriptions/update#create_invoice) as soon as you make the subscription change. That will collect the proration adjustments into a new invoice, and Stripe will automatically attempt to collect payment on the invoice. /n If you don't want to prorate at all, set the prorate option to `false` and the customer would be billed $100 on May 1 and $200 on June 1. Similarly, if you set prorate to `false` when switching between different billing intervals (monthly to yearly, for example), we won't generate any credits for the old subscription's unused time—although we will still reset the billing date and will bill immediately for the new subscription.
    ///
    /// - Parameters:
    ///   - subscription: The ID of the subscription to update.
    ///   - addInvoiceItems: A list of prices and quantities that will generate invoice items appended to the first invoice for this subscription. You may pass up to 10 items.
    ///   - applicationFeePercent: A non-negative decimal between 0 and 100, with at most two decimal places. This represents the percentage of the subscription invoice subtotal that will be transferred to the application owner’s Stripe account. The request must be made with an OAuth key in order to set an application fee percentage. For more information, see the application fees documentation.
    ///   - billingCycleAnchor: Either `now` or `unchanged`. Setting the value to now resets the subscription’s billing cycle anchor to the current time. For more information, see the billing cycle documentation.
    ///   - billingThresholds: Define thresholds at which an invoice will be sent, and the subscription advanced to a new billing period. Pass an empty string to remove previously-defined thresholds.
    ///   - cancelAt: A timestamp at which the subscription should cancel. If set to a date before the current period ends, this will cause a proration if prorations have been enabled using proration_behavior. If set during a future period, this will always cause a proration for that period.
    ///   - cancelAtPeriodEnd: Boolean indicating whether this subscription should cancel at the end of the current period.
    ///   - collectionMethod: Either `charge_automatically`, or `send_invoice`. When charging automatically, Stripe will attempt to pay this subscription at the end of the cycle using the default source attached to the customer. When sending an invoice, Stripe will email your customer an invoice with payment instructions. Defaults to `charge_automatically`.
    ///   - coupon: The code of the coupon to apply to this subscription. A coupon applied to a subscription will only affect invoices created for that particular subscription. This will be unset if you POST an empty value.
    ///   - daysUntilDue: Number of days a customer has to pay invoices generated by this subscription. Valid only for subscriptions where billing is set to send_invoice.
    ///   - defaultPaymentMethod: ID of the default payment method for the subscription. It must belong to the customer associated with the subscription. If not set, invoices will use the default payment method in the customer’s invoice settings.
    ///   - defaultSource: ID of the default payment source for the subscription. It must belong to the customer associated with the subscription and be in a chargeable state. If not set, defaults to the customer’s default source.
    ///   - defaultTaxRates: The tax rates that will apply to any subscription item that does not have tax_rates set. Invoices created will have their default_tax_rates populated from the subscription.
    ///   - items: List of subscription items, each with an attached plan.
    ///   - metadata: A set of key-value pairs that you can attach to a subscription object. This can be useful for storing additional information about the subscription in a structured format.
    ///   - offSession: Indicates if a customer is on or off-session while an invoice payment is attempted.
    ///   - pauseCollection: If specified, payment collection for this subscription will be paused.
    ///   - paymentBehavior: Use `allow_incomplete` to create subscriptions with `status=incomplete` if its first invoice cannot be paid. Creating subscriptions with this status allows you to manage scenarios where additional user actions are needed to pay a subscription’s invoice. For example, SCA regulation may require 3DS authentication to complete payment. See the [SCA Migration Guide](https://stripe.com/docs/billing/migration/strong-customer-authentication) for Billing to learn more. This is the default behavior. Use `error_if_incomplete` if you want Stripe to return an HTTP 402 status code if a subscription’s first invoice cannot be paid. For example, if a payment method requires 3DS authentication due to SCA regulation and further user action is needed, this parameter does not create a subscription and returns an error instead. This was the default behavior for API versions prior to 2019-03-14. See the [changelog](https://stripe.com/docs/upgrades#2019-03-14) to learn more.
    ///   - pendingInvoiceItemInterval: Specifies an interval for how often to bill for any pending invoice items. It is analogous to calling [Create an invoice](https://stripe.com/docs/api#create_invoice) for the given subscription at the specified interval.
    ///   - prorationBehavior: Determines how to handle prorations when the billing cycle changes (e.g., when switching plans, resetting `billing_cycle_anchor=now`, or starting a trial), or if an item’s quantity changes. Valid values are `create_prorations`, `none`, or `always_invoice`. Passing `create_prorations` will cause proration invoice items to be created when applicable. These proration items will only be invoiced immediately under certain conditions. In order to always invoice immediately for prorations, pass `always_invoice`. Prorations can be disabled by passing `none`.
    ///   - prorationDate: If set, the proration will be calculated as though the subscription was updated at the given time. This can be used to apply exactly the same proration that was previewed with [upcoming invoice](https://stripe.com/docs/api/subscriptions/update#retrieve_customer_invoice) endpoint. It can also be used to implement custom proration logic, such as prorating by day instead of by second, by providing the time that you wish to use for proration calculations.
    ///   - transferData: If specified, the funds from the subscription’s invoices will be transferred to the destination and the ID of the resulting transfers will be found on the resulting charges. This will be unset if you POST an empty value.
    ///   - trialEnd: Unix timestamp representing the end of the trial period the customer will get before being charged for the first time. This will always overwrite any trials that might apply via a subscribed plan. If set, `trial_end` will override the default trial period of the plan the customer is being subscribed to. The special value `now` can be provided to end the customer’s trial immediately. Can be at most two years from `billing_cycle_anchor`.
    ///   - trialFromPlan: Indicates if a plan’s `trial_period_days` should be applied to the subscription. Setting `trial_end` per subscription is preferred, and this defaults to `false`. Setting this flag to true together with `trial_end` is not allowed.
    ///   - expand: An array of properties to expand.
    /// - Returns: A `StripeSubscription`.
    func update(subscription: String,
                addInvoiceItems: [[String: Any]]?,
                applicationFeePercent: Decimal?,
                billingCycleAnchor: String?,
                billingThresholds: [String: Any]?,
                cancelAt: Date?,
                cancelAtPeriodEnd: Bool?,
                collectionMethod: StripeInvoiceCollectionMethod?,
                coupon: String?,
                daysUntilDue: Int?,
                defaultPaymentMethod: String?,
                defaultSource: String?,
                defaultTaxRates: [String]?,
                items: [[String: Any]]?,
                metadata: [String: String]?,
                offSession: Bool?,
                pauseCollection: [String: Any]?,
                paymentBehavior: StripeSubscriptionPaymentBehavior?,
                pendingInvoiceItemInterval: [String: Any]?,
                prorationBehavior: StripeSubscriptionProrationBehavior?,
                prorationDate: Date?,
                transferData: [String: Any]?,
                trialEnd: Any?,
                trialFromPlan: Bool?,
                expand: [String]?) -> EventLoopFuture<StripeSubscription>
    
    /// Cancels a customer’s subscription immediately. The customer will not be charged again for the subscription. /n Note, however, that any pending invoice items that you’ve created will still be charged for at the end of the period, unless manually [deleted](https://stripe.com/docs/api/subscriptions/cancel#delete_invoiceitem) . If you’ve set the subscription to cancel at the end of the period, any pending prorations will also be left in place and collected at the end of the period. But if the subscription is set to cancel immediately, pending prorations will be removed. /n By default, upon subscription cancellation, Stripe will stop automatic collection of all finalized invoices for the customer. This is intended to prevent unexpected payment attempts after the customer has canceled a subscription. However, you can resume automatic collection of the invoices manually after subscription cancellation to have us proceed. Or, you could check for unpaid invoices before allowing the customer to cancel the subscription at all.

    ///
    /// - Parameters:
    ///   - subscription: ID of the subscription to cancel.
    ///   - invoiceNow: Will generate a final invoice that invoices for any un-invoiced metered usage and new/pending proration invoice items.
    ///   - prorate: Will generate a proration invoice item that credits remaining unused time until the subscription period end.
    ///   - expand: An array of properties to expand.
    /// - Returns: A `StripeSubscription`.
    func cancel(subscription: String,
                invoiceNow: Bool?,
                prorate: Bool?,
                expand: [String]?) -> EventLoopFuture<StripeSubscription>
    
    /// By default, returns a list of subscriptions that have not been canceled. In order to list canceled subscriptions, specify status=canceled.
    ///
    /// - Parameter filter: A dictionary that will be used for the query parameters. [See More →](https://stripe.com/docs/api/subscriptions/list)
    /// - Returns: A `StripeSubscriptionList`.
    func listAll(filter: [String: Any]?) -> EventLoopFuture<StripeSubscriptionList>
    
    /// Headers to send with the request.
    var headers: HTTPHeaders { get set }
}

extension SubscriptionRoutes {
    public func create(customer: String,
                       addInvoiceItems: [[String: Any]]? = nil,
                       applicationFeePercent: Decimal? = nil,
                       backdateStartDate: Date? = nil,
                       billingCycleAnchor: Date? = nil,
                       billingThresholds: [String: Any]? = nil,
                       cancelAt: Date? = nil,
                       cancelAtPeriodEnd: Bool? = nil,
                       collectionMethod: StripeInvoiceCollectionMethod? = nil,
                       coupon: String? = nil,
                       daysUntilDue: Int? = nil,
                       defaultPaymentMethod: String? = nil,
                       defaultSource: String? = nil,
                       defaultTaxRates: [String]? = nil,
                       items: [[String: Any]],
                       metadata: [String: String]? = nil,
                       offSession: Bool? = nil,
                       paymentBehavior: StripeSubscriptionPaymentBehavior? = nil,
                       pendingInvoiceItemInterval: [String: Any]? = nil,
                       prorationBehavior: StripeSubscriptionProrationBehavior? = nil,
                       transferData: [String: Any]? = nil,
                       trialEnd: Any? = nil,
                       trialFromPlan: Bool? = nil,
                       trialPeriodDays: Int? = nil,
                       expand: [String]? = nil) -> EventLoopFuture<StripeSubscription> {
        return create(customer: customer,
                      addInvoiceItems: addInvoiceItems,
                      applicationFeePercent: applicationFeePercent,
                      backdateStartDate: backdateStartDate,
                      billingCycleAnchor: billingCycleAnchor,
                      billingThresholds: billingThresholds,
                      cancelAt: cancelAt,
                      cancelAtPeriodEnd: cancelAtPeriodEnd,
                      collectionMethod: collectionMethod,
                      coupon: coupon,
                      daysUntilDue: daysUntilDue,
                      defaultPaymentMethod: defaultPaymentMethod,
                      defaultSource: defaultSource,
                      defaultTaxRates: defaultTaxRates,
                      items: items,
                      metadata: metadata,
                      offSession: offSession,
                      paymentBehavior: paymentBehavior,
                      pendingInvoiceItemInterval: pendingInvoiceItemInterval,
                      prorationBehavior: prorationBehavior,
                      transferData: transferData,
                      trialEnd: trialEnd,
                      trialFromPlan: trialFromPlan,
                      trialPeriodDays: trialPeriodDays,
                      expand: expand)
    }
    
    public func retrieve(id: String, expand: [String]? = nil) -> EventLoopFuture<StripeSubscription> {
        return retrieve(id: id, expand: expand)
    }
    
    public func update(subscription: String,
                       addInvoiceItems: [[String: Any]]? = nil,
                       applicationFeePercent: Decimal? = nil,
                       billingCycleAnchor: String? = nil,
                       billingThresholds: [String: Any]? = nil,
                       cancelAt: Date? = nil,
                       cancelAtPeriodEnd: Bool? = nil,
                       collectionMethod: StripeInvoiceCollectionMethod? = nil,
                       coupon: String? = nil,
                       daysUntilDue: Int? = nil,
                       defaultPaymentMethod: String? = nil,
                       defaultSource: String? = nil,
                       defaultTaxRates: [String]? = nil,
                       items: [[String: Any]]? = nil,
                       metadata: [String: String]? = nil,
                       offSession: Bool? = nil,
                       pauseCollection: [String: Any]? = nil,
                       paymentBehavior: StripeSubscriptionPaymentBehavior? = nil,
                       pendingInvoiceItemInterval: [String: Any]? = nil,
                       prorationBehavior: StripeSubscriptionProrationBehavior? = nil,
                       prorationDate: Date? = nil,
                       transferData: [String: Any]? = nil,
                       trialEnd: Any? = nil,
                       trialFromPlan: Bool? = nil,
                       expand: [String]? = nil) -> EventLoopFuture<StripeSubscription> {
        return update(subscription: subscription,
                      addInvoiceItems: addInvoiceItems,
                      applicationFeePercent: applicationFeePercent,
                      billingCycleAnchor: billingCycleAnchor,
                      billingThresholds: billingThresholds,
                      cancelAt: cancelAt,
                      cancelAtPeriodEnd: cancelAtPeriodEnd,
                      collectionMethod: collectionMethod,
                      coupon: coupon,
                      daysUntilDue: daysUntilDue,
                      defaultPaymentMethod: defaultPaymentMethod,
                      defaultSource: defaultSource,
                      defaultTaxRates: defaultTaxRates,
                      items: items,
                      metadata: metadata,
                      offSession: offSession,
                      pauseCollection: pauseCollection,
                      paymentBehavior: paymentBehavior,
                      pendingInvoiceItemInterval: pendingInvoiceItemInterval,
                      prorationBehavior: prorationBehavior,
                      prorationDate: prorationDate,
                      transferData: transferData,
                      trialEnd: trialEnd,
                      trialFromPlan: trialFromPlan,
                      expand: expand)
    }
    
    public func cancel(subscription: String,
                       invoiceNow: Bool? = nil,
                       prorate: Bool? = nil,
                       expand: [String]? = nil) -> EventLoopFuture<StripeSubscription> {
        return cancel(subscription: subscription,
                      invoiceNow: invoiceNow,
                      prorate: prorate,
                      expand: expand)
    }
    
    public func listAll(filter: [String: Any]? = nil) -> EventLoopFuture<StripeSubscriptionList> {
        return listAll(filter: filter)
    }
}

public struct StripeSubscriptionRoutes: SubscriptionRoutes {
    public var headers: HTTPHeaders = [:]
    
    private let apiHandler: StripeAPIHandler
    private let subscriptions = APIBase + APIVersion + "subscriptions"
    
    init(apiHandler: StripeAPIHandler) {
        self.apiHandler = apiHandler
    }
    
    public func create(customer: String,
                       addInvoiceItems: [[String: Any]]?,
                       applicationFeePercent: Decimal?,
                       backdateStartDate: Date?,
                       billingCycleAnchor: Date?,
                       billingThresholds: [String: Any]?,
                       cancelAt: Date?,
                       cancelAtPeriodEnd: Bool?,
                       collectionMethod: StripeInvoiceCollectionMethod?,
                       coupon: String?,
                       daysUntilDue: Int?,
                       defaultPaymentMethod: String?,
                       defaultSource: String?,
                       defaultTaxRates: [String]?,
                       items: [[String: Any]],
                       metadata: [String: String]?,
                       offSession: Bool?,
                       paymentBehavior: StripeSubscriptionPaymentBehavior?,
                       pendingInvoiceItemInterval: [String: Any]?,
                       prorationBehavior: StripeSubscriptionProrationBehavior?,
                       transferData: [String: Any]?,
                       trialEnd: Any?,
                       trialFromPlan: Bool?,
                       trialPeriodDays: Int?,
                       expand: [String]?) -> EventLoopFuture<StripeSubscription> {
        var body: [String: Any] = ["customer": customer,
                                   "items": items]
        
        if let addInvoiceItems = addInvoiceItems {
            body["add_invoice_items"] = addInvoiceItems
        }
        
        if let applicationFeePercent = applicationFeePercent {
            body["application_fee_percent"] = applicationFeePercent
        }
        
        if let backdateStartDate = backdateStartDate {
            body["backdate_start_date"] = Int(backdateStartDate.timeIntervalSince1970)
        }
        
        if let billingCycleAnchor = billingCycleAnchor {
            body["billing_cycle_anchor"] = Int(billingCycleAnchor.timeIntervalSince1970)
        }
        
        if let billingThresholds = billingThresholds {
            billingThresholds.forEach { body["billing_thresholds[\($0)]"] = $1 }
        }
        
        if let cancelAt = cancelAt {
            body["cancel_at"] = Int(cancelAt.timeIntervalSince1970)
        }
        
        if let cancelAtPeriodEnd = cancelAtPeriodEnd {
            body["cancel_at_period_end"] = cancelAtPeriodEnd
        }
        
        if let collectionMethod = collectionMethod {
            body["collection_method"] = collectionMethod.rawValue
        }
        
        if let coupon = coupon {
            body["coupon"] = coupon
        }
        
        if let daysUntilDue = daysUntilDue {
            body["days_until_due"] = daysUntilDue
        }
        
        if let defaultPaymentMethod = defaultPaymentMethod {
            body["default_payment_method"] = defaultPaymentMethod
        }
        
        if let defaultSource = defaultSource {
            body["default_source"] = defaultSource
        }
        
        if let defaultTaxRates = defaultTaxRates {
            body["default_tax_rates"] = defaultTaxRates
        }
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }
        
        if let offSession = offSession {
            body["off_session"] = offSession
        }
        
        if let paymentBehavior = paymentBehavior {
            body["payment_behavior"] = paymentBehavior.rawValue
        }
        
        if let pendingInvoiceItemInterval = pendingInvoiceItemInterval {
            pendingInvoiceItemInterval.forEach { body["pending_invoice_item_interval[\($0)]"] = $1 }
        }
        
        if let prorationBehavior = prorationBehavior {
            body["proration_behavior"] = prorationBehavior.rawValue
        }
        
        if let transferData = transferData {
            transferData.forEach { body["transfer_data[\($0)]"] = $1 }
        }
        
        if let trialEnd = trialEnd as? Date {
            body["trial_end"] = Int(trialEnd.timeIntervalSince1970)
        }
        
        if let trialEnd = trialEnd as? String {
            body["trial_end"] = trialEnd
        }
        
        if let trialFromPlan = trialFromPlan {
            body["trial_from_plan"] = trialFromPlan
        }
        
        if let trialPeriodDays = trialPeriodDays {
            body["trial_period_days"] = trialPeriodDays
        }
        
        if let expand = expand {
            body["expand"] = expand
        }
        
        return apiHandler.send(method: .POST, path: subscriptions, body: .string(body.queryParameters), headers: headers)
    }
    
    public func retrieve(id: String, expand: [String]?) -> EventLoopFuture<StripeSubscription> {
        var queryParams = ""
        if let expand = expand {
            queryParams = ["expand": expand].queryParameters
        }
        return apiHandler.send(method: .GET, path: "\(subscriptions)/\(id)", query: queryParams, headers: headers)
    }
    
    public func update(subscription: String,
                       addInvoiceItems: [[String: Any]]?,
                       applicationFeePercent: Decimal?,
                       billingCycleAnchor: String?,
                       billingThresholds: [String: Any]?,
                       cancelAt: Date?,
                       cancelAtPeriodEnd: Bool?,
                       collectionMethod: StripeInvoiceCollectionMethod?,
                       coupon: String?,
                       daysUntilDue: Int?,
                       defaultPaymentMethod: String?,
                       defaultSource: String?,
                       defaultTaxRates: [String]?,
                       items: [[String: Any]]?,
                       metadata: [String: String]?,
                       offSession: Bool?,
                       pauseCollection: [String: Any]?,
                       paymentBehavior: StripeSubscriptionPaymentBehavior?,
                       pendingInvoiceItemInterval: [String: Any]?,
                       prorationBehavior: StripeSubscriptionProrationBehavior?,
                       prorationDate: Date?,
                       transferData: [String: Any]?,
                       trialEnd: Any?,
                       trialFromPlan: Bool?,
                       expand: [String]?) -> EventLoopFuture<StripeSubscription> {
        var body: [String: Any] = [:]
        
        if let addInvoiceItems = addInvoiceItems {
            body["add_invoice_items"] = addInvoiceItems
        }
        
        if let applicationFeePercent = applicationFeePercent {
            body["application_fee_percent"] = applicationFeePercent
        }
        
        if let billingCycleAnchor = billingCycleAnchor {
            body["billing_cycle_anchor"] = billingCycleAnchor
        }
        
        if let billingThresholds = billingThresholds {
            billingThresholds.forEach { body["billing_thresholds[\($0)]"] = $1 }
        }
        
        if let cancelAt = cancelAt {
            body["cancel_at"] = Int(cancelAt.timeIntervalSince1970)
        }
        
        if let cancelAtPeriodEnd = cancelAtPeriodEnd {
            body["cancel_at_period_end"] = cancelAtPeriodEnd
        }
        
        if let collectionMethod = collectionMethod {
            body["collection_method"] = collectionMethod.rawValue
        }
        
        if let coupon = coupon {
            body["coupon"] = coupon
        }
        
        if let daysUntilDue = daysUntilDue {
            body["days_until_due"] = daysUntilDue
        }
        
        if let defaultPaymentMethod = defaultPaymentMethod {
            body["default_payment_method"] = defaultPaymentMethod
        }
        
        if let defaultSource = defaultSource {
            body["default_source"] = defaultSource
        }
        
        if let defaultTaxRates = defaultTaxRates {
            body["default_tax_rates"] = defaultTaxRates
        }
        
        if let items = items {
            body["items"] = items
        }
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }
        
        if let offSession = offSession {
            body["off_session"] = offSession
        }
        
        if let pauseCollection = pauseCollection {
            pauseCollection.forEach { body["pause_collection[\($0)]"] = $1 }
        }
        
        if let paymentBehavior = paymentBehavior {
            body["payment_behavior"] = paymentBehavior.rawValue
        }
        
        if let pendingInvoiceItemInterval = pendingInvoiceItemInterval {
            pendingInvoiceItemInterval.forEach { body["pending_invoice_item_interval[\($0)]"] = $1 }
        }
        
        if let prorationBehavior = prorationBehavior {
            body["proration_behavior"] = prorationBehavior.rawValue
        }
        
        if let prorationDate = prorationDate {
            body["proration_date"] = Int(prorationDate.timeIntervalSince1970)
        }
        
        if let transferData = transferData {
            transferData.forEach { body["transfer_data[\($0)]"] = $1 }
        }
        
        if let trialEnd = trialEnd as? Date {
            body["trial_end"] = Int(trialEnd.timeIntervalSince1970)
        }
        
        if let trialFromPlan = trialFromPlan {
            body["trial_from_plan"] = trialFromPlan
        }

        if let expand = expand {
            body["expand"] = expand
        }
        
        return apiHandler.send(method: .POST, path: "\(subscriptions)/\(subscription)", body: .string(body.queryParameters), headers: headers)
    }
    
    public func cancel(subscription: String,
                       invoiceNow: Bool?,
                       prorate: Bool?,
                       expand: [String]?) -> EventLoopFuture<StripeSubscription> {
        var body: [String: Any] = [:]
        
        if let invoiceNow = invoiceNow {
            body["invoice_now"] = invoiceNow
        }
        
        if let prorate = prorate {
            body["prorate"] = prorate
        }
        
        if let expand = expand {
            body["expand"] = expand
        }
        
        return apiHandler.send(method: .DELETE, path: "\(subscriptions)/\(subscription)", body: .string(body.queryParameters), headers: headers)
    }
    
    public func listAll(filter: [String : Any]?) -> EventLoopFuture<StripeSubscriptionList> {
        var queryParams = ""
        if let filter = filter {
            queryParams = filter.queryParameters
        }
        
        return apiHandler.send(method: .GET, path: subscriptions, query: queryParams, headers: headers)
    }
}
