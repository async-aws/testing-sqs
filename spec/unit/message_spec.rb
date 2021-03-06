require 'fake_sqs/message'

RSpec.describe FakeSQS::Message do

  describe "#body" do

    it "is extracted from the MessageBody" do
      message = create_message("MessageBody" => "abc")
      expect(message.body).to eq "abc"
    end

  end

  describe "#md5" do

    it "is calculated from body" do
      message = create_message("MessageBody" => "abc")
      expect(message.md5).to eq "900150983cd24fb0d6963f7d28e17f72"
    end

  end

  describe "#message_attributes" do
    it "has message attributes" do
      body = {"MessageBody" => "abc"}
      attributes = create_attributes [
          {name: "one", string_value: "A String Value", data_type:"String"},
          {name: "two", string_value: "35", data_type:"Number"},
          {name: "three", binary_value: "c29tZSBiaW5hcnkgZGF0YQ==", data_type:"Binary"}
      ]
      message = create_message(body.merge attributes)

      expect(message.message_attributes.size).to eq 3
      expect(message.message_attributes_md5).to eq "6d31a67b8fa3c1a74d030c5de73fd7e2"
    end

    it "calculates string attribute md5" do
      body = {"MessageBody" => "abc"}
      attributes = create_attributes [
          {name: "one", string_value: "A String Value", data_type:"String"}
      ]
      message = create_message(body.merge attributes)

      expect(message.message_attributes_md5).to eq "88bb810f131daa54b83485598cc35693"
    end

    it "calculates number attribute md5" do
      body = {"MessageBody" => "abc"}
      attributes = create_attributes [
        {name: "two", string_value: "35", data_type:"Number"}
      ]
      message = create_message(body.merge attributes)

      expect(message.message_attributes_md5).to eq "7eb7af82e3ed82aef934e78b9ed11f12"
    end

    it "calculates binary attribute md5" do
      body = {"MessageBody" => "abc"}
      attributes = create_attributes [
        {name: "three", binary_value: "c29tZSBiaW5hcnkgZGF0YQ==", data_type: "Binary"}
      ]
      message = create_message(body.merge attributes)

      expect(message.message_attributes_md5).to eq "c0f297612d491707df87d6444ecb4817"
    end
  end

  describe "#id" do

    it "is generated" do
      message = create_message
      expect(message.id.size).to eq 36
    end

  end

  describe "#delay_seconds" do

    it "is generated" do
      message = create_message({"DelaySeconds" => 10})
      expect(message.delay_seconds).to eq 10
    end

  end

  describe 'visibility_timeout' do

    let :message do
      create_message
    end

    it 'should default to nil' do
      expect(message.visibility_timeout).to eq nil
    end

    it 'should be expired when it is nil' do
      expect(message).to be_expired
    end

    it 'should be expired if set to a previous time' do
      message.visibility_timeout = Time.now - 1
      expect(message).to be_expired
    end

    it 'should not be expired at a future date' do
      message.visibility_timeout = Time.now + 1
      expect(message).not_to be_expired
    end

    it 'should not be expired when set to expire at a future date' do
      message.expire_at(5)
      expect(message.visibility_timeout).to be >=(Time.now + 4)
    end

  end

  def create_message(options = {})
    FakeSQS::Message.new({"MessageBody" => "test"}.merge(options))
  end

  def create_attributes(attributes = [])
    result = {}

    attributes.each_with_index do |attribute, index|
      result["MessageAttribute.#{index+1}.Name"] = attribute[:name] if attribute[:name]
      result["MessageAttribute.#{index+1}.Value.StringValue"] = attribute[:string_value] if attribute[:string_value]
      result["MessageAttribute.#{index+1}.Value.BinaryValue"] = attribute[:binary_value] if attribute[:binary_value]
      result["MessageAttribute.#{index+1}.Value.DataType"] = attribute[:data_type] if attribute[:data_type]
    end

    result
  end
end
