require "commandable"

module TopModule
  class ParentClass
    module WhatWhat
      class OhNoYouDian
        module OhYesIDid
          module TwoSnapsUpIn
            class ACircle
              module Exclamation
                module OKEvenImBoredNow
                  class DeepDeepClass
                    extend Commandable
                    command 'this is a really deep method call'
                    def super_deep_method
                      "you called a deep method"
                    end 
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end