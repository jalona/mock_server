# encoding: utf-8
class Mockdata < ActiveRecord::Base

  validates :mock_name, presence: true
  validates :mock_http_status, presence: true, format: {with: /\A[12345]\d{2}\z/, message: '.Please enter a valid HTTP code.'}
  validates :mock_request_url, presence: true
  validates :mock_http_verb, presence: true
  validates :mock_data_response_headers, presence: true
  validate :validate_headers
  validate :mock_data_response_body
  validates :mock_content_type, presence: true
  validates :mock_environment, presence: true
  validate :validate_script_state
  validate :validate_script_name


  before_save do
    self.mock_name = self.mock_name.gsub(/\s+/, ' ').strip.upcase
    self.mock_http_verb = self.mock_http_verb.upcase
    self.mock_served_times = 0 if self.mock_served_times.nil?
    self.after_script_name = self.after_script_name.nil? ? nil : after_script_name
    self.before_script_name = self.before_script_name.nil? ? nil : before_script_name
    self.profile_name = self.profile_name.nil? ? '' : self.profile_name.gsub(/\s+/, ' ').strip.upcase
  end

  def mock_data_response_body
    if self.mock_http_status.match(/^[^4-5]/) && self.mock_data_response.size == 0
      errors.add(:mock_data_response, "can't be blank.")
    end
  end

  def validate_headers
    supplied_headers = self.mock_data_response_headers.split(/\r\n/)
    supplied_headers.each do |header_data|
      errors.add(mock_data_response_headers, " ** Header #{header_data} is not delimited correctly **") unless header_data.match(ENV['HEADER_DELIMITER'])
    end
  end

  def validate_script_name
    if (!self.before_script_name.nil? && self.before_script_name.length > 0)
      if self.before_script_name.match(/\A\w+\.rb\z/)
      else
        errors.add(:before_script_name, '- Script name should end with .rb')
      end
    end

    if (!self.after_script_name.nil? && self.after_script_name.length > 0)
      if self.after_script_name.match(/\A\w+\.rb\z/)
      else
        errors.add(:after_script_name, '- Script name should end with .rb')
      end
    end
  end

  def validate_script_state
    if self.has_before_script == true
      p 'Has before script'
      if (self.before_script_name.nil? || self.before_script_name.length == 0)
        errors.add(:before_script_name, '- Provide a before script name ending with .rb')
      end
    end

    if self.has_after_script == true
      p 'Has before script'
      if (self.after_script_name.nil? || self.after_script_name.length == 0)
        errors.add(:after_script_name, '- Provide a after script name ending with .rb')
      end
    end
  end

end