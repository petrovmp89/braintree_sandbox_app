require 'rubygems'
require 'braintree'
require 'sinatra'

set :bind, '0.0.0.0'
set :port, 9494

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = ENV["BRAIN_TREE_MERCHANT_ID"]
Braintree::Configuration.public_key = ENV["BRAIN_TREE_PUBLIC_KEY"]
Braintree::Configuration.private_key = ENV["BRAIN_TREE_PRIVATE_KEY"]

get '/client_token' do
  Braintree::ClientToken.generate
end

post '/checkout' do
  result = Braintree::Transaction.sale(
    amount: params[:amount],
    payment_method_nonce: params[:payment_method_nonce],
    options: {
      submit_for_settlement: true
    }
  )

  if result.success?
    "success!: #{result.transaction.inspect}"
  elsif result.transaction
    'Error processing transaction:'
    "  code: #{result.transaction.processor_response_code}"
    "  text: #{result.transaction.processor_response_text}"
  else
    result.errors
  end
end

not_found do
  status 404
  'Incorrect request'
end
