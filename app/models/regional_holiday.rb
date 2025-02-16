# frozen_string_literal: true

class RegionalHoliday < ApplicationRecord
  has_and_belongs_to_many :cities

  validates :name, :day, :month, presence: true
  validate :date_validation

  def self.to_formatted_hash
    all.map { |h| { month: h.month, day: h.day } }
  end

  def cities_names
    cities.pluck(:name).to_sentence
  end

  private

  def valid_date?
    day.present? && month.present? &&
      Date.valid_date?(Date.today.year, month, day)
  end

  def date_validation
    errors.add(:base, 'date must be valid') unless valid_date?
  end
end
