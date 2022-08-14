module CurrentCart

  private

  def set_cart
    @cart = Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    @cart = Cart.create
    session[:cart_id] = @cart.id
  end

  def set_counter
       if session[:counter].nil?
         @counter = 1
         session[:counter] = 1
       else
         @counter = session[:counter]
         @counter += 1
         session[:counter] = @counter
       end
  end
end
