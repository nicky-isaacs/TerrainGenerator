class User < ActiveRecord::Base

  ADMIN_USERS = %w(
      'nicholas.isaacs@colorado.edu',
      'miles.rufatlatre@colorado.edu',
      'mitchell.wolfe@colorado.edu'
  )

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

	#before_filter :authenticate_user!

	# user_signed_in?

	# current_user

	# user_session

  def is_admin?
    ADMIN_USERS.include? email.downcase
  end

end
