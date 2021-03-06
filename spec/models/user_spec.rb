# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:loa_one) { { current: LOA::ONE } }
  let(:loa_three) { { current: LOA::THREE } }

  describe '.from_merged_attrs()' do
    subject(:loa1_user) { build(:loa1_user) }
    subject(:loa3_user) { build(:loa3_user) }
    it 'should not down-level' do
      user = described_class.from_merged_attrs(loa3_user, loa1_user)
      expect(user.loa[:current]).to eq(loa3_user.loa[:current])
      expect(user.loa[:highest]).to eq(loa3_user.loa[:highest])
      expect(user).to be_valid
    end
    it 'should up-level' do
      user = described_class.from_merged_attrs(loa1_user, loa3_user)
      expect(user.loa[:current]).to eq(loa3_user.loa[:current])
      expect(user.loa[:highest]).to eq(loa3_user.loa[:highest])
      expect(user).to be_valid
    end
    it 'should use newer attrs unless they are empty or nil' do
      new_user = build(:loa1_user, first_name: 'George', last_name: 'Washington', gender: '', birth_date: nil)
      user = described_class.from_merged_attrs(loa3_user, new_user)
      expect(user.first_name).to eq('George')
      expect(user.last_name).to eq('Washington')
      expect(user.gender).to eq(loa3_user.gender)
      expect(user.birth_date).to eq(loa3_user.birth_date)
      expect(user.zip).to eq(loa3_user.zip)
    end
  end

  describe '.create()' do
    context 'with LOA 1' do
      subject(:loa1_user) { described_class.new(FactoryGirl.build(:user, loa: loa_one)) }
      it 'should allow a blank ssn' do
        expect(FactoryGirl.build(:user, loa: loa_one, ssn: '')).to be_valid
      end
      it 'should allow a blank gender' do
        expect(FactoryGirl.build(:user, loa: loa_one, gender: '')).to be_valid
      end
      it 'should allow a blank middle_name' do
        expect(FactoryGirl.build(:user, loa: loa_one, middle_name: '')).to be_valid
      end
      it 'should allow a blank birth_date' do
        expect(FactoryGirl.build(:user, loa: loa_one, birth_date: '')).to be_valid
      end
      it 'should allow a blank zip' do
        expect(FactoryGirl.build(:user, loa: loa_one, zip: '')).to be_valid
      end
      it 'should allow a blank loa.highest' do
        expect(FactoryGirl.build(:user, loa: { current: LOA::ONE, highest: '' })).to be_valid
      end
      it 'should not allow a blank uuid' do
        loa1_user.uuid = ''
        expect(loa1_user.valid?).to be_falsey
        expect(loa1_user.errors[:uuid].size).to be_positive
      end
      it 'should not allow a blank email' do
        loa1_user.email = ''
        expect(loa1_user.valid?).to be_falsey
        expect(loa1_user.errors[:email].size).to be_positive
      end
    end
    context 'with LOA 3' do
      subject(:loa3_user) { described_class.new(FactoryGirl.build(:user, loa: loa_three)) }
      it 'should not allow a blank ssn' do
        loa3_user.ssn = ''
        expect(loa3_user.valid?(:loa3_user)).to be_falsey
        expect(loa3_user.errors[:ssn].size).to be_positive
      end
      it 'should not allow a blank first_name' do
        loa3_user.first_name = ''
        expect(loa3_user.valid?(:loa3_user)).to be_falsey
        expect(loa3_user.errors[:first_name].size).to be_positive
      end
      it 'should not allow a blank last_name' do
        loa3_user.last_name = ''
        expect(loa3_user.valid?(:loa3_user)).to be_falsey
        expect(loa3_user.errors[:last_name].size).to be_positive
      end
      it 'should not allow a blank birth_date' do
        loa3_user.birth_date = ''
        expect(loa3_user.valid?(:loa3_user)).to be_falsey
        expect(loa3_user.errors[:birth_date].size).to be_positive
      end
      it 'should allow a blank gender' do
        loa3_user.gender = ''
        expect(loa3_user.valid?(:loa3_user)).to be_truthy
        expect(loa3_user.errors[:gender].size).to eq(0)
      end
      it 'should allow a nil gender' do
        loa3_user.gender = nil
        expect(loa3_user.valid?(:loa3_user)).to be_truthy
        expect(loa3_user.errors[:gender].size).to eq(0)
      end
      it 'should not allow a gender other than M or F' do
        loa3_user.gender = 'male'
        expect(loa3_user.valid?(:loa3_user)).to be_falsey
        expect(loa3_user.errors[:gender].size).to be_positive
        loa3_user.gender = 'female'
        expect(loa3_user.valid?(:loa3_user)).to be_falsey
        expect(loa3_user.errors[:gender].size).to be_positive
        loa3_user.gender = 'Z'
        expect(loa3_user.valid?(:loa3_user)).to be_falsey
        expect(loa3_user.errors[:gender].size).to be_positive
      end
      it 'should allow a gender of M' do
        loa3_user.gender = 'M'
        expect(loa3_user.valid?(:loa3_user)).to be_truthy
      end
      it 'should allow a gender of F' do
        loa3_user.gender = 'F'
        expect(loa3_user.valid?(:loa3_user)).to be_truthy
      end
    end
  end

  subject { described_class.new(FactoryGirl.build(:user)) }
  context 'with an invalid ssn' do
    it 'should have an error on ssn' do
      subject.ssn = '111-22-3333'
      expect(subject.valid?(:loa3_user)).to be_falsey
      expect(subject.errors[:ssn].size).to eq(1)
    end
  end

  context 'user without attributes' do
    let(:test_user) { FactoryGirl.build(:user) }
    it 'expect ttl to an Integer' do
      expect(subject.ttl).to be_an(Integer)
      expect(subject.ttl).to be_between(-Float::INFINITY, 0)
    end

    it 'assigns an email' do
      expect(subject.email).to eq(test_user.email)
    end

    it 'assigns an uuid' do
      expect(subject.uuid).to eq(test_user.uuid)
    end

    it 'has a persisted attribute of false' do
      expect(subject.persisted?).to be_falsey
    end
  end

  it 'has a persisted attribute of false' do
    expect(subject.persisted?).to be_falsey
  end

  describe 'redis persistence' do
    before(:each) { subject.save }

    describe '#save' do
      it 'sets persisted flag to true' do
        expect(subject.persisted?).to be_truthy
      end

      it 'sets the ttl countdown' do
        expect(subject.ttl).to be_an(Integer)
        expect(subject.ttl).to be_between(0, 86_400)
      end
    end

    describe '.find' do
      let(:found_user) { described_class.find(subject.uuid) }

      it 'can find a saved user in redis' do
        expect(found_user).to be_a(described_class)
        expect(found_user.uuid).to eq(subject.uuid)
      end

      it 'expires and returns nil if user loaded from redis is invalid' do
        allow_any_instance_of(described_class).to receive(:valid?).and_return(false)
        expect(found_user).to be_nil
      end

      it 'returns nil if user was not found' do
        expect(described_class.find('non-existant-uuid')).to be_nil
      end
    end

    describe '#destroy' do
      it 'can destroy a user in redis' do
        expect(subject.destroy).to eq(1)
        expect(described_class.find(subject.uuid)).to be_nil
      end
    end

    describe '#mhv_correlation_id' do
      context 'when mhv ids are nil' do
        let(:user) { FactoryGirl.build(:user) }
        it 'has a mhv correlation id of nil' do
          expect(user.mhv_correlation_id).to be_nil
        end
      end
      context 'when there are mhv ids' do
        let(:loa3_user) { FactoryGirl.build(:loa3_user) }
        it 'has a mhv correlation id' do
          expect(loa3_user.mhv_correlation_id).to eq('123456')
        end
      end
    end
  end
end
