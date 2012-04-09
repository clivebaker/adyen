module Adyen
  module API
    class PaymentService < SimpleSOAPClient
      class << self
        private

        def modification_request(method, body = nil)
          return <<EOS
    <ns1:#{method} xmlns:ns1="http://payment.services.adyen.com">
      <ns1:modificationRequest>
        <ns1:merchantAccount>%s</ns1:merchantAccount>
        <ns1:originalReference>%s</ns1:originalReference>
        #{body}
      </ns1:modificationRequest>
    </ns1:#{method}>
EOS
        end

        def modification_request_with_amount(method)
          modification_request(method, <<EOS)
        <ns1:modificationAmount>
          <currency xmlns="http://common.services.adyen.com">%s</currency>
          <value xmlns="http://common.services.adyen.com">%s</value>
        </ns1:modificationAmount>
EOS
        end
      end

      # @private
      CAPTURE_LAYOUT          = modification_request_with_amount(:capture)
      # @private
      REFUND_LAYOUT           = modification_request_with_amount(:refund)
      # @private
      CANCEL_LAYOUT           = modification_request(:cancel)
      # @private
      CANCEL_OR_REFUND_LAYOUT = modification_request(:cancelOrRefund)

      # @private
      LAYOUT = <<EOS
    <ns1:authorise xmlns:ns1="http://payment.services.adyen.com">
      <ns1:paymentRequest>
        <ns1:merchantAccount>%s</ns1:merchantAccount>
        <ns1:reference>%s</ns1:reference>
%s
      </ns1:paymentRequest>
    </ns1:authorise>
EOS

      # @private
      AMOUNT_PARTIAL = <<EOS
        <amount xmlns="http://payment.services.adyen.com">
          <currency  xmlns="http://common.services.adyen.com">%s</currency>
          <value  xmlns="http://common.services.adyen.com">%s</value>
        </amount>
EOS

      # @private
      CARD_PARTIAL = <<EOS
        <ns1:card>
          <ns1:holderName>%s</ns1:holderName>
          <ns1:number>%s</ns1:number>
          <ns1:cvc>%s</ns1:cvc>
          <ns1:expiryYear>%s</ns1:expiryYear>
          <ns1:expiryMonth>%02d</ns1:expiryMonth>
        </ns1:card>
EOS

      # @private
      ENABLE_RECURRING_CONTRACTS_PARTIAL = <<EOS
        <ns1:recurring>
          <ns1:contract>RECURRING,ONECLICK</ns1:contract>
        </ns1:recurring>
EOS

      # @private
      RECURRING_PAYMENT_BODY_PARTIAL = <<EOS
        <ns1:recurring>
          <ns1:contract>RECURRING</ns1:contract>
        </ns1:recurring>
        <ns1:selectedRecurringDetailReference>%s</ns1:selectedRecurringDetailReference>
        <ns1:shopperInteraction>ContAuth</ns1:shopperInteraction>
EOS

      # @private
      ONE_CLICK_PAYMENT_BODY_PARTIAL = <<EOS
        <ns1:recurring>
          <ns1:contract>ONECLICK</ns1:contract>
        </ns1:recurring>
        <ns1:selectedRecurringDetailReference>%s</ns1:selectedRecurringDetailReference>
        <ns1:card>
          <ns1:cvc>%s</ns1:cvc>
        </ns1:card>
EOS

      # @private
      SHOPPER_PARTIALS = {
        :reference => '        <ns1:shopperReference>%s</ns1:shopperReference>',
        :email     => '        <ns1:shopperEmail>%s</ns1:shopperEmail>',
        :ip        => '        <ns1:shopperIP>%s</ns1:shopperIP>',
        :statement => '        <ns1:shopperStatement>%s</ns1:shopperStatement>',
      }
    end
  end
end
