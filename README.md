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

## What's it for

Suppose you have a controller action that needs to do a few things, like
1) check something can be edited
2) check the submitted changes are valid
3) implement those changes
4) notify someone that changes were made

If you don't want to put all these steps, or all the logic around when to carry them out, in your controller, you might want to use OrchestratedService.

OrchestratedService takes responsibility for the orchestrating logic. It puts that logic in one place - the OrchestratedService::Orchestrate module - away from your controllers.

And it removes the implementation of each step from your controllers. That implementation moves to OrchestratedService::Service objects, which your controller actions delegate to, or to separate, reusable objects employed by OrchestratedService::Service objects.

## How?

In your controller, delegate to an object that inherits from `OrchestratedService::Service`. It's helpful to namespace that object so it references the particular controller and controller action it carries out. `Actions::Teams::Update` for the `teams#update` controller action, for example.

(Note that here the controller also includes OrchestratedService::StandardFailure, which just brings in a helpful `handle_fail` method for determining whether to `redirect` or `render` if there's a failure, and where to redirect to or what view to render.)

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

Make `Actions::Teams::Update` an `OrchestratedService::Service` object by inheriting from `OrchestratedService::Service`.

Implement `Actions::Teams::Update` by listing the steps it needs to carry out, in order, as arguments to the `steps` method, called from within `call`. Each step corresponds to a private method of the same name that's responsible for carrying out the step, either directly or by invoking some other object.

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
          OrchestratedService::Feedback.new(success: false, result: OrchestratedService::Failure.new('Validation errors', type: :now, alert: 'Failed to create Team', next: :edit))
        end
      end

      def notify_team_users
        Notify.call(recipients: @result[:update_team].members, template: :team_update)
      end
    end
  end
end
```

## What's going on?

An instance of `Actions::Teams::Update` is initialized, with the argument passed into `Actions::Teams::Update.call` made available as `params`.

`.call` is then called on the `Actions::Teams::Update` instance, which calls `steps`, provided by the `OrchestratedService::Orchestrate` module included in the `OrchestratedService::Service`.

The `steps` method manages the execution of the steps, carrying each out when they need to be, allowing them to build on each other, and reporting back on what happens:
- each step is carried out in turn, until a step fails, in which case the remaning steps won't be carried out.
- calling `.success` on the result returned to the controller returns `true` if all the steps were successfully carried out, or else `false`.
- calling `.result[:success]` returns the result of the final step if all the steps succeeded.
- calling `.result[:fail]` returns the result of the failed step if one of the steps failed.
- steps can make use of the results from previous steps. Each has access to the `@result` variable, a hash of steps and their results. For example, the `update_team` step uses the form object initialized in the `form` step by referring to `@result[:form]`, which returns the the result of the `form` step.
- the controller has access to the results of all the steps that were carried out, by calling `.result[name_of_step]`.
- if you configure the gem to use `OrchestratedService::StepsWrappers::ActiveRecord` as the steps wrapper, the steps will by default be wrapped in a transaction. When a step fails, any database commits from previous steps will be rolled back. Changes made by a step are not just available to later steps, they depend on later steps succeeding, so you don't have to worry about manually undoing steps that were part of an unfinished whole.

Each individual step can do anything you need. The only requirement is that it must return an instance of `OrchestratedService::Feedback`. This sets the status and result of the step. If the step fails, you need to pass in `success: false` when initializing the `Feedback` object. And the result of the step, made available to other steps and reported back to the controller, must be passed into `result: ...`.

## Failures

In the example above, the results returned by failed steps are instances of `OrchestratedService::Failure`. This just an abbreviated way to tell the controller whether the failure calls for a `redirect` or a `render`, what to display in a `flash` message, and where to redirect to or what view to render.

Initialize `OrchestratedService::Failure` with an explanation message as the first argument, plus these options:
- `type: :now` if the controller should render rather than redirect. If it should redirect no `type` argument is needed.
- `alert: '...'` to set a flash message. If an `alert` argument is not passed through, the explanation message will be used instead.
- `next: '...'` to determine where to redirect or (if `type: now` was passed in), what view to render. This can be a string, giving the url or view path, or a symbol, giving the name of a path helper method or the action of the view to render.

The controller then just needs to call `handle_fail(called.result[:fail])` if there is a failed step. This `handle_fail` method comes from the `OrchestratedService::StandardFailure` module, which must be included in the controller.

## Nesting Steps

A step method can carry out its step directly, or it can invoke any other object to perform the necessary tasks.

It could use an object then set an `OrchestratedService::Feedback` instance depending on what the object ruturns, as in the `update_team` step, which uses an `UpdateTeamForm` object.

Or it could use an object that itself returns an `OrchestratedService::Feedback` instance.

In fact, the step could invoke another `OrchestratedService::Service` object, as in the `notify_team_users` step. Here `Notify` inherits from `OrchestratedService::Service`, so the `steps` method will be called again with `Notify`'s list of steps. The result will be an `OrchestratedService::Feedback` object with `success` set to false if any of its steps failed, and its `result` set to the full `@result` hash providing the results of all of its steps that were carried out. Helpfully, when the controller action calls `.result[:success]` it will actually get the result of the final step successfully carried out in `Notify`'s set of steps - it gets bubbled up to be the successful result of `Actions::Teams::Update`, the first `OrchestratedService::Service` called. And if a `Notify` step failed, the result of that failed step would bubble up to be returned by `.result[:fail]` called in the controller. This means you can nest objects that carry out steps and will always have access to the result of the step that ultimately led to failure or success.

## Soft Stop

What if you want to stop running through a set of steps without it counting as a failure? No problem. A `OrchestratedService::Feedback` object can be initialized with `soft_stop: true`. This prevents the remaining steps from being carried out, without setting `success` to false in the response returned to the controller. As far as the controller is concerned, there was no failure, and `.result[:success]` will return the result of the final step that was carried out.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ollieh-m/orchestrated_service. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

