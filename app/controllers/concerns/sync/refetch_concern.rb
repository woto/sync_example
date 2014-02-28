require 'active_support/concern'

module Sync::RefetchConcern
  extend ActiveSupport::Concern

  included do

    respond_to :json

    before_filter :require_valid_request, only: [:refetch]
    before_filter :find_resource, only: [:refetch]
    before_filter :find_authorized_partial, only: [:refetch]

    def refetch
      render json: {
        html: with_format(:html){ @partial.render_to_string }
      }
    end

    private

    def with_format(format, &block)
      old_formats = formats
      self.formats = [format]
      block_value = block.call
      self.formats = old_formats

      block_value
    end

    def require_valid_request
      render_bad_request unless request_valid?
    end

    def request_valid?
      [
        params[:resource_name],
        params[:partial_name],
        params[:auth_token]
      ].all?(&:present?)
    end

    def find_resource

      @resource = common_filter(params[:resource_name].to_s.classify.safe_constantize).where(id: params[:resource_id]).try(:first)

      #@resource = Sync::RefetchModel.find_by_class_name_and_id(
      #  params[:resource_name],
      #  params[:resource_id]
      #) || render_bad_request
    end

    def find_authorized_partial
      #binding.pry
      @partial = Sync::RefetchPartial.find_by_authorized_resource(
        @resource,
        params[:partial_name],
        self,
        params[:auth_token]
      ) || render_bad_request
    end

    def render_bad_request
      head :bad_request
    end
  end
end
