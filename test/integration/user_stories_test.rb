require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  # 
  fixtures :products
  include ActiveJob::TestHelper
  #用户访问在线商店的目录页面，选择一个商品，把它添加到购物车中。
  #然后去结算，在表单中填写自己的详细信息。当他点击提交按钮时，
  #一个包含了他的信息的订单就在数据库中生成了
  #其中还包含了他添加到购物车中的产品所对应的商品。

  test "buying a product" do 
    start_order_count = Order.count
    ruby_book = products(:ruby)

    get "/"
    assert_response :success
    assert_select 'h1', "Your Pramatic Catalog"

    post '/line_items', params: { product_id: ruby_book.id }, xhr: true
    assert_response :success

    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    get "/orders/new"
    assert_response :success
    assert_select "legend", "Please Enter Your Details"

    perform_enqueued_jobs do
      post "/orders", params: {
        order: {
          name: "Dave Thomas",
          address: "123 The Street",
          email: "dave@example.com",
          pay_type: "Check"
        }
      }

      follow_redirect!

      assert_response :success
      assert_select "h1", "Your Pramatic Catalog"
      cart = Cart.find(session[:cart_id])
      assert_equal 0, cart.line_items.size

      assert_equal start_order_count + 1, Order.count
      order = Order.last

      assert_equal "Dave Thomas", order.name
      assert_equal "123 The Street", order.address
      assert_equal "dave@example.com", order.email
      assert_equal "Check", order.pay_type


      assert_equal 1, order.line_items.size
      line_item = order.line_items[0]
      assert_equal ruby_book, line_item.product

      mail = ActionMailer::Base.deliveries.last
      assert_equal ["dave@example.com"], mail.to
      assert_equal "Sam Ruby <depot@example.com>", mail[:from].value
      assert_equal "Pragmatic Store Order Confirmation", mail.subject
    end
end
end
