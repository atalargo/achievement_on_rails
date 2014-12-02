module AchieverEngine
    module Behaviour

        class Abstract

            protected

            def self.inherited(sub)
                class << sub
                    cattr_accessor :type

                    def check
                        throw Exception.new('The method \'check\' must be overloaded in ' + self.class_name);
                    end
                end

                sub.class_eval <<-METHOD
                    private

                    def self.typing(sym)
                        self.type = sym
                        AchieverEngine::Behaviour.send :append_behaviour, self
                    end
                METHOD

#                 AchieverEngine::Behaviour.send :append_behaviour, sub
            end
        end

        def self.append_behaviour(behav)
            @@_behaviours_list[behav.type] = behav
        end

        def self.get_behaviour(behav_name)
            @@_behaviours_list[behav_name.to_sym]
        end

        def self.behaviours_list
            @@_behaviours_list.keys
        end

        private
        @@_behaviours_list = {}
    end
end
