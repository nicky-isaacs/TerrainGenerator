class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ADMIN_USER_EMAILS = %w(
    nisaacs.skiracer@gmail.com
    miles.rufatlatre@colorado.edu
    mitchell.wolfe@colorado.edu
  )

  def create_session_key(data)
    session[:id].to_s + Digest::MD5.hexdigest(data.to_s).to_s
  end

  def cache_file(key, data, extension=nil)
    begin FileUtils.mkdir_p(Rails.root, 'tmp', 'obj_caching'); rescue; end
    path = File.join(Rails.root, 'tmp', 'obj_caching', key)
    path += extension if extension

    file = File.new path, "w+"
    file << data
    file.close
    path
  end

  def is_admin?
    ADMIN_USER_EMAILS.include? current_user.email.downcase
  end

end
