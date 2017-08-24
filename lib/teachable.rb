require "teachable/version"
require 'faraday'
require 'json'

API_URL = "https://fast-bayou-75985.herokuapp.com"

module Teachable
  class User
    attr_reader :id, :name, :nickname, :image, :email, :tokens, :created_at, :updated_at

    def self.authenticate(email, password)
      response = connection.post '/users/sign_in.json',
                                 {
                                   user:
                                    {
                                      email: email,
                                      password: password
                                    }
                                 }
      body = JSON.parse(response.body)

      if (error = body["errors"] || body["error"])
        raise "Error: #{error}"
      end

      return new(body)
    end

    def self.register_new_user(email, password, password_confirmation)
      raise "Error: password and password_confirmation must match" unless password == password_confirmation
      response = connection.post '/users.json',
                                  {
                                    user:
                                      {
                                        email: email,
                                        password: password,
                                        password_confirmation: password_confirmation
                                      }
                                  }
      body = JSON.parse(response.body)

      if (error = body["errors"] || body["error"])
        raise "Error: #{body["errors"]}"
      end

      return new(body)
    end

    def get_user_details
      response = connection.get '/api/users/current_user/edit.json',
                                {
                                  user_email: self.email,
                                  user_token: self.tokens
                                }
      body = JSON.parse(response.body)

      if (error = body["errors"] || body["error"])
        raise "Error: #{body["errors"]}"
      end

      return User.new(body)
    end

    def get_orders_for_user
      response = connection.get '/api/orders.json',
                                {
                                  user_email: self.email,
                                  user_token: self.tokens
                                }
      body = JSON.parse(response.body)

      if (body.class != Array && error = body["errors"] || body["error"])
        raise "Error: #{error}"
      end

      if body.empty?
        return body
      else
        return body.map{ |order| Order.new(order) }
      end
    end

    def create_order_for_user(total, total_quantity)
      response = connection.post "/api/orders.json?user_email=#{self.email}&user_token=#{self.tokens}",
                                {
                                  order:
                                  {
                                    total: total,
                                    total_quantity: total_quantity,
                                    email: self.email
                                  }
                                }

      body = JSON.parse(response.body)

      if (error = body["errors"] || body["error"])
        raise "Error: #{body["errors"]}"
      else
        return Order.new(body)
      end
    end

    def delete_order_for_user(order_id)
      response = connection.delete "/api/orders/#{order_id}.json",
                                   {
                                    user_email: self.email,
                                    user_token: self.tokens
                                   }
      if response.body.empty?
        return "Order:#{order_id} deleted!"
      else
        return JSON.parse(response.body)
      end
    end

    private

    def self.connection
      @conn ||= Faraday.new(url: API_URL)
    end

    def connection
      self.class.connection
    end

    def initialize(attributes)
      @id = attributes["id"]
      @name = attributes["name"]
      @nickname = attributes["nickname"]
      @image = attributes["image"]
      @email = attributes["email"]
      @tokens = attributes["tokens"]
      @created_at = attributes["created_at"]
      @updated_at = attributes["updated_at"]
    end
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
