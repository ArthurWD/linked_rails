# frozen_string_literal: true

class Record < ApplicationRecord
  include LinkedRails::Model

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable

  belongs_to :parent, class_name: 'Record'
  has_many :children, class_name: 'Record', foreign_key: :parent_id

  with_collection :records

  filterable key: {key: :actual_key, values: {value: 'actual_value'}}, key2: {}, key3: {values: {empty: 'NULL'}}

  def self.default_per_page
    11
  end

  def body=(value)
    super(value.presence)
  end
end
