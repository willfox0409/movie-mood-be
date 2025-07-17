require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do 
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  describe 'password authentication' do 
    it 'authenticates with a correct password' do 
      user = User.create(username: 'testuser', email: 'test@example.com', password: 'ParisTexas123')

      expect(user.authenticate('ParisTexas123')).to eq(user)
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end
end
