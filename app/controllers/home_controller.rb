# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @posts = Post.order(created_at: :desc).limit(10)
  end
end
