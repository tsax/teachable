require "teachable/version"
require 'faraday'
require 'json'

API_URL = "https://fast-bayou-75985.herokuapp.com"

module Teachable
  # Your code goes here...
  def authenticate(email, password)
  	response = connection.post '/users/sign_in.json', 
  						 						{
  						 							user: 
  						 								{
  						 									email: email,
  						 							 		password: password
  						 								}
  						 						}
  	return JSON.parse(response.body)
  end

  def register_new_user(email, password, password_confirmation)
  	response = connection.post '/users.json', 
  												{
  													user:
  													{
  														email: email,
  														password: password,
  														password_confirmation: password_confirmation
  													}
  												}
  	return JSON.parse(response.body)
  end

  def get_user_details(email, token)
  	response = connection.get '/api/users/current_user/edit.json', 
  												{
  													user_email: email,
  													user_token: token
  												}
  	return JSON.parse(response.body)
  end

  def get_orders_for_user(email, token)
  	response = connection.get '/api/orders.json',
  												{
  													user_email: email,
  													user_token: token
  												}
  	return JSON.parse(response.body)
  end

  def create_order_for_user(email, token, total, total_quantity)
  	response = connection.post "/api/orders.json?user_email=#{email}&user_token=#{token}",
  												{
  													order:
  													{
  														total: total,
  														total_quantity: total_quantity,
  														email: email
  													}
  												}
    return JSON.parse(response.body)
  end

  def delete_order_for_user(email, token, order_id)
  	response = connection.delete "/api/orders/#{order_id}.json",
  												{
  													user_email: email,
  													user_token: token
  												}
    return JSON.parse(response.body)
  end

  def connection
  	conn ||= Faraday.new(url: API_URL)
  end

  class Order
  	attr_reader :id, :email, :number, :total, :total_quantity, 
  							:special_instructions, :created_at, :updated_at

  	def initialize(attributes)
  		@id = attributes["id"]
  		@email = attributes["email"]
  		@number = attributes["number"]
  		@total = attributes["total"]
  		@total_quantity = attributes["total_quantity"]
  		@special_instructions = attributes["special_instructions"]
  		@created_at = attributes["created_at"]
  		@updated_at = attributes["updated_at"]
  	end
  end
end
