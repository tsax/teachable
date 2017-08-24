require "spec_helper"
require 'vcr'
require 'faker'
require 'support/vcr_setup'

RSpec.describe Teachable do
  it "has a version number" do
    expect(Teachable::VERSION).not_to be nil
  end

  describe "register new user" do
    let(:user_email) 		{ "whatever22@example.com" }
    let(:user_password) { "password" }

    it "when password and password_confirmation don't match" do
      expect{ Teachable::User.register_new_user(user_email, user_password, "random") }
        .to raise_error('Error: password and password_confirmation must match')
    end

    it "when using existing email, throws an error" do
      VCR.use_cassette('new_user_error') do
        expect{ Teachable::User.register_new_user(user_email,
                                                  user_password,
                                                  user_password) }
          .to raise_error('Error: {"email"=>["has already been taken"]}')
      end
    end

    context "when using a new email" do
      let(:user_email) 		{ Faker::Internet.email }
      let(:user_password)	{ "password" }

      it "returns a new user" do
        VCR.use_cassette('new_user', match_requests_on: [:headers,:body], record: :new_episodes) do
          user = Teachable::User.register_new_user(user_email,
                                                   user_password,
                                                   user_password)
          expect(user.class).to eq(Teachable::User)
          expect(user.email).to eq(user_email)
        end
      end
    end
  end

  describe "authenticate existing user" do
    let(:user_email) 		{ "whatever22@example.com" }
    let(:user_password) { "password" }

    it "returns a User object when login is successful" do
      VCR.use_cassette('authenticate_success') do
        user = Teachable::User.authenticate(user_email, user_password)

        expect(user.class).to eq(Teachable::User)
        expect(user.email).to eq(user_email)
        expect(user.tokens).not_to eq(nil)
      end
    end

    context "when login is unsuccessful" do
      let(:user_email) 	  { "whatever22@example.com" }
      let(:user_password) { "password1" }

      it "raises an error" do
        VCR.use_cassette('authenticate_error') do
          expect { Teachable::User.authenticate(user_email, user_password) }
            .to raise_error("Error: Invalid email or password.")
        end
      end
    end
  end

  describe "get details of existing user" do
    let(:user_email)  	{ "whatever22@example.com" }
    let(:user_password) { "password" }

    it "raises an error" do
      VCR.use_cassette('user_details') do
        user = Teachable::User.authenticate(user_email, user_password)
        user_copy = user.get_user_details

        expect(user.email).to eq(user_copy.email)
        expect(user.tokens).to eq(user_copy.tokens)
      end
    end
  end

  describe "get orders for user" do
    let(:user_email) 		{ "tsax@example.com" }
    let(:user_password) { "password" }

    let(:u_email) { "dev-11111@example.com" }
    let(:u_password) { "password" }

    before do
      VCR.use_cassette('tsax_user') do
        @user = Teachable::User.authenticate(user_email, user_password)
      end

      VCR.use_cassette('no_orders_user') do
        @no_orders_user = Teachable::User.authenticate(u_email, u_password)
      end
    end

    it "when user has orders, it gets orders" do
      VCR.use_cassette('user_orders') do
        orders = @user.get_orders_for_user
        expect(orders.class).to eq(Array)
      end
    end

    context 'when user does not have any orders' do
      it "returns an empty array" do
        VCR.use_cassette('no_orders') do
          orders = @no_orders_user.get_orders_for_user
          expect(orders).to eq([])
        end
      end
    end
  end

  describe "create an order for user" do
    context 'for a user with no orders' do
      let(:u_email) { "dev-11111@example.com" }
      let(:u_password) { "password" }
      let(:total) { "50.0" }
      let(:total_quantity) { 100 }

      before do
        VCR.use_cassette('no_orders_user') do
          @no_orders_user = Teachable::User.authenticate(u_email, u_password)
        end
      end

      after do
        @no_orders_user.get_orders_for_user.each do |order|
          @no_orders_user.delete_order_for_user(order.id)
        end
      end

      it "creates an order" do
        order = @no_orders_user.create_order_for_user(total, total_quantity)
        expect(order.email).to eq(u_email)
        expect(order.total).to eq(total)
        expect(order.total_quantity).to eq(total_quantity)
      end
    end
  end

  describe "delete an order" do
    before do
      VCR.use_cassette('tsax_user') do
        @op_user = Teachable::User.authenticate("tsax@example.com", "password")
      end
    end

    after do
      @op_user.create_order_for_user(50, 100)
    end

    it "deletes an order" do
      old_orders = @op_user.get_orders_for_user
      old_count = old_orders.count
      @op_user.delete_order_for_user(old_orders.first.id)

      new_orders = @op_user.get_orders_for_user
      new_count = new_orders.count

      expect(new_count).to eq(old_count - 1)
    end
  end
end
