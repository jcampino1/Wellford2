module PumpsHelper
  def ya_postulo(user_id)
    Request.all.each do |request|
      if (request.user_id == user_id)
        return true
      else
        return false
      end
    end
    false
  end
end
