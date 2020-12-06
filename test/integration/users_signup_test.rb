require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
     @user = users(:michael)
    ActionMailer::Base.deliveries.clear
   
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                               email: "user@invalid",
                               password:              "foo",
                               password_confirmation: "bar" } }
    end
    assert_template 'users/new'
  end

    test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                            email: "user@example.com",
                                            password:              "password",
                                            password_confirmation: "password" } }
                                         
    end
    user = assigns(:user)
    assert_not user.activated?
    # Попытка войти до активации
    log_in_as(user)
    assert_not is_logged_in?
    # Невалидный активационный токен
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    # Валидный токен, неверный адрес электронной почты
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Валидный активационный токен и адрес почты
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
