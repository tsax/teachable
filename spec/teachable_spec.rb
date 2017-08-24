require "spec_helper"
require 'vcr'
require 'support/vcr_setup'

RSpec.describe Teachable do
  it "has a version number" do
    expect(Teachable::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(true).to eq(true)
  end

  describe "register new user" do
  	let(:user_email) 		{ "whatever22@example.com" }
  	let(:user_password) { "password" }

  	it "when using existing email, throws an error" do
  		VCR.use_cassette('new_user_error') do
  			expect{ Teachable::User.register_new_user(user_email,
  																							 user_password,
  																							 user_password) }
  			.to raise_error('Error: {"email"=>["has already been taken"]}')
  		end
  	end

  	context "when using a new email" do
  		let(:user_email) 		{ "new_email22@example.com" }
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
  end

  describe "get details of existing user" do
  end

  describe "get orders for user" do
  end

  describe "create an order for user" do
  end

  describe "delete an order for user" do
  end
end
