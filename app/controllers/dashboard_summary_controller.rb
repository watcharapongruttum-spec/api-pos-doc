# app/controllers/dashboard_summary_controller.rb
class DashboardSummaryController < ApplicationController
  def summary
    today = Time.zone.today

    render json: {
      users_count: User.count,
      categories_count: Category.count,
      products_count: SkuMaster.count,

      receipts_count: Receipt.count,
      receipts_today_count: Receipt.where(
        created_at: today.beginning_of_day..today.end_of_day
      ).count,

      carts_active_count: Cart.where(status: "active").count
    }
  end
end

