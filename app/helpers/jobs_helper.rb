module JobsHelper
  def rowsForDescription description
    if description.blank?
      '3'
    else
      ((description.length / 70) > 20 ? 20 : (description.length / 70)).to_s
    end
  end
end
