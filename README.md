# OrchestratedService

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/orchestrated_service`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'orchestrated_service'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install orchestrated_service

## Usage

Suppose you have a controller action that needs to do a few things, like  
1) check something can be edited  
2) if it can be edited, check the changes in submitted params are valid  
3) if the changes are valid, implement those changes, and  
4) notify someone that changes were made  

If you don't want to put these steps - or all the logic around when to carry them out - in your controller, you might want to use OrchestratedService. It takes responsibility for the orchestrating logic, putting that logic in one place (the OrchestratedService::Orchestrate module), away from your controllers. And it removes the implementation of each step from your controllers, putting it inside OrchestratedService::Service objects, or separate objects entirely that can be used by various OrchestratedService::Service objects.

In your controller, delegate to an OrchestratedService::Service object, here called an Action.
```
class TeamsController < ApplicationController
  include OrchestratedService::StandardFailure

  def update
    called = Actions::Teams::Update.call(params)
    if called.success
      flash[:notice] = 'Team successfully updated.'
      redirect_to root_path
    else
      @update_team_form = called.result[:form]
      handle_fail(called.result[:fail])
    end
  end
end
```

Make that Action object an OrchestratedService::Service by inheriting from OrchestratedService::Service:
```
module Actions
  module Teams
    class Update < OrchestratedService::Service

      def call
        steps(
          :check,
          :form,
          :update_team,
          :notify_team_users
        )
      end

      private

      def check
        team = Team.find_by(name: params[:team][:name])
        if team.editable?
          OrchestratedService::Feedback.new(result: team)
        else
          OrchestratedService::Feedback.new(success: false, result: 'Team cannot be edited')
        end
      end
      
      def form
        OrchestratedService::Feedback.new(result: UpdateTeamForm.new(@result[:check]))
      end

      def update_team
        if @result[:form].validate(params[:team]) && @result[:form].save
          OrchestratedService::Feedback.new(result: @result[:form].model)
        else
          Feedback.new(success: false, result: OrchestratedService::Failure.new('Validation errors', type: :now, alert: 'Failed to create Team', next: :edit))
        end
      end

      def notify_team_users
        Notify.call(recipients: @result[:update_team].members, template: :team_update)
      end
    end
  end
end

Here's what's going on in the above example:
...



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ollieh-m/orchestrated_service. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

