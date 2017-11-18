module OrchestratedService

  module StandardFailure

    def handle_fail(failure)
      if failure.now
        flash.now[:alert] = failure.alert
        render failure.next
      else
        flash[:alert] = failure.alert
        redirect_to failure.next
      end
    end

  end

end
