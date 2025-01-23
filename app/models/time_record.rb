class TimeRecord < ApplicationRecord
  belongs_to :user
  
  validates :date, presence: true
  validates :clock_in, presence: true
  validate :one_record_per_day_per_user, on: :create

  private

  def one_record_per_day_per_user
    if TimeRecord.exists?(user: user, date: date)
      errors.add(:base, 'Ya existe un registro para este usuario en esta fecha')
    end
  end
end
