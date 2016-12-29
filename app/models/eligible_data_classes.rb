# frozen_string_literal: true
require 'common/models/base'
require 'digest'

# BlueButton EligibleDataClasses
class EligibleDataClasses < Common::Base
  attribute :data_classes, Array[String]

  # checksum of the original attributes returned for uniqueness
  def id
    Digest::MD5.hexdigest(instance_variable_get(:@original_attributes).to_json)
  end

  # EligibleDataClasses are simply an array, and you can't really compare an array of arrays
  def <=>(other)
    data_class_id <=> other.data_class_id
  end
end
