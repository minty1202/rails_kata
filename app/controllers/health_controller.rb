class HealthController < ApplicationController
  def check
    render json: { ok: true }
  end
end
