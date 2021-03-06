# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.includes(:source).joins(:source).where(sources: { active: true, site_visible: true}).order(created_at: :desc)
    @posts = @posts.where(source_id: JSON.parse(cookies.signed[:source_ids])) if cookies.signed[:source_ids].present?
    @posts = @posts.fulltext_search(params[:search]) if params[:search].present?
    @page = (params[:page] || 1).to_i
    @pagy, @posts = pagy_countless(@posts, items: 20)
  end

  def create
    if params[:source_ids].present?
      if params[:source_ids].size == Source.count
        cookies.delete(:source_ids)
      else
        cookies.signed.permanent[:source_ids] = JSON.generate(params[:source_ids])
      end
    else
      cookies.delete(:source_ids)
    end

    redirect_to root_path
  end
end
