$:.unshift File.expand_path((File.dirname(__FILE__) + '/../../lib'))
require "commandable"

module TopModule
  class ParentClass
    module WhatWhat
      class OhNoYouDian
        module OhYesIDid
          module TwoSnapsUpIn
            class ACircle
              module Exlamation
                module OKEvenImBoredNow
                  class DeepClass1
                    extend Commandable
                    command 'this is a deep method call'
                    def deep_method1
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