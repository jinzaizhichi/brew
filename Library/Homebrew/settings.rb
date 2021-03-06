# typed: true
# frozen_string_literal: true

require "system_command"

module Homebrew
  # Helper functions for reading and writing settings.
  #
  # @api private
  module Settings
    extend T::Sig
    include SystemCommand::Mixin

    module_function

    sig { params(setting: T.any(String, Symbol), repo: Pathname).returns(T.nilable(String)) }
    def read(setting, repo: HOMEBREW_REPOSITORY)
      return unless (repo/".git/config").exist?

      repo.cd do
        Utils.popen_read("git", "config", "--get", "homebrew.#{setting}").chomp.presence
      end
    end

    sig { params(setting: T.any(String, Symbol), value: T.any(String, T::Boolean), repo: Pathname).void }
    def write(setting, value, repo: HOMEBREW_REPOSITORY)
      return unless (repo/".git/config").exist?

      repo.cd do
        system_command! "git", args: ["config", "--replace-all", "homebrew.#{setting}", value.to_s]
      end
    end

    sig { params(setting: T.any(String, Symbol), repo: Pathname).void }
    def delete(setting, repo: HOMEBREW_REPOSITORY)
      return unless (repo/".git/config").exist?
      return if read(setting, repo: repo).blank?

      repo.cd do
        system_command! "git", args: ["config", "--unset-all", "homebrew.#{setting}"]
      end
    end
  end
end
