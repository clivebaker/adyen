module Adyen
  module API
    class PaymentService < SimpleSOAPClient
      class << self
        private

        def modification_request(method, body = nil)
          return <<EOS
    <ns1:#{method} xmlns:payment="http://payment.services.adyen.com" xmlns:recurring="http://recurring.services.adyen.com" xmlns:common="http://common.services.adyen.com">
      <ns1:modificationRequest>
        <ns1:merchantAccount>%s</payment:merchantAccount>
        <ns1:originalReference>%s</payment:originalReference>
        #{body}
      </ns1:modificationRequest>
    </ns1:#{method}>
EOS
        end

        def modification_request_with_amount(method)
          modification_request(method, <<EOS)
        <ns1:modificationAmount>
          <common:currency>%s</common:currency>
          <common:value>%s</common:value>
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
    <ns1:authorise xmlns:payment="http://payment.services.adyen.com" xmlns:recurring="http://recurring.services.adyen.com" xmlns:common="http://common.services.adyen.com">
      <ns1:paymentRequest>
        <ns1:merchantAccount>%s</ns1:merchantAccount>
        <ns1:reference>%s</ns1:reference>
%s
      </ns1:paymentRequest>
    </ns1:authorise>
EOS

      # @private
      AMOUNT_PARTIAL = <<EOS
        <amount>
          <currency>%s</currency>
          <value>%s</value>
        </amount>
EOS

      # @private
      CARD_PARTIAL = <<EOS
        <payment:card>
          <payment:holderName>%s</payment:holderName>
          <payment:number>%s</payment:number>
          <payment:cvc>%s</payment:cvc>
          <payment:expiryYear>%s</payment:expiryYear>
          <payment:expiryMonth>%02d</payment:expiryMonth>
        </payment:card>
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
        <payment:recurring>
          <payment:contract>ONECLICK</payment:contract>
        </payment:recurring>
        <payment:selectedRecurringDetailReference>%s</payment:selectedRecurringDetailReference>
        <payment:card>
          <payment:cvc>%s</payment:cvc>
        </payment:card>
EOS

      # @private
      SHOPPER_PARTIALS = {
        :reference => '        <payment:shopperReference>%s</payment:shopperReference>',
        :email     => '        <payment:shopperEmail>%s</payment:shopperEmail>',
        :ip        => '        <payment:shopperIP>%s</payment:shopperIP>',
        :statement => '        <payment:shopperStatement>%s</payment:shopperStatement>',
      }
    end
  end
end
