
module AchieverEngine
    module Config


        mattr_accessor :init_cache
        @@init_cache = false

        mattr_accessor :block_available_after_progress
        @@block_available_after_progress = false

        mattr_accessor :use_redis
        @@use_redis = false

        @@base_behaviour_path = [File.dirname(__FILE__) + '/Behaviour']
        @@behaviours_list = {}

        mattr_accessor :extra_behaviours_paths
        @@extra_behaviours_paths = nil

        def self.parse_configuration
            unless @@extra_behaviours_paths.nil?
                @@extra_behaviours_paths = [@@extra_behaviours_paths] if !@@extra_behaviours_paths.is_a? Array
                @@base_behaviour_path = @@base_behaviour_path.concat( @@extra_behaviours_paths).uniq
            end

            @@base_behaviour_path.each do |path|
                p path
                Dir.glob(File.join(path,"*.rb")).each do |behaviour_file|
                    p behaviour_file
                    camelname = File.basename(behaviour_file, '.rb').camelize
                    @@behaviours_list[camelname] = behaviour_file
                end
                p @@behaviours_list
            end

            @@behaviours_list.keys.each do |class_name|
#                 autoload class_name.to_sym, @@behaviours_list[class_name]
                require @@behaviours_list[class_name]
            end

        end

        def self.get_behaviour(behaviour_name)

        end
    end
end