require "spec_helper"
require 'vcr'
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
  		let(:user_email) 		{ "new_email11@example.com" }
  		let(:user_password)	{ "password" }

  		it "returns a new user" do
  			VCR.use_cassette('new_user') do
  				user = Teachable::User.register_new_user(user_email,
  					user_password,
  					user_password)
  				puts user
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
  		let(:user_email) 		{ "whatever22@example.com" }
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
		let(:user_email) 		{ "whatever22@example.com" }
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

		before do
			VCR.use_cassette('tsax_user') do
				@user = Teachable::User.authenticate(user_email, user_password)
			end
		end
		it "gets orders" do
			VCR.use_cassette('user_orders') do
				orders = @user.get_orders_for_user
				expect(orders.class).to eq(Array)
			end
		end
  end

  describe "create an order for user" do
  end

  describe "delete an order for user" do
  end
end
