module Test
    module Bench
        class Search

            def execute
                t1 = Time.new
                t = nil
                Benchmark.bm do |x|
                    x.report('get_available_for_user full AchievementRelation') do
                        t = Benchmark.realtime {
                            AchieverEngine::Search.get_available_for_user(:project_id => 4, :user_id => 2)
                        }
                    end
                end
                print "\nTime elapsed : #{t * 1000} ms in bm\n"
                print "\nTime elapsed : #{(Time.now - t1) * 1000.0} ms out bm\n"

                t1 = Time.new
                t = nil
                Benchmark.bm do |x|
                    x.report('get_available_for_user_by_nanoc by Nanoc') do
                        t = Benchmark.realtime {
                            AchieverEngine::Search.get_available_for_user_by_nanoc(:project_id => 4, :user_id => 2)
                        }
                    end
                end
                print "\nTime elapsed : #{t * 1000} ms in bm\n"
                print "\nTime elapsed : #{(Time.now - t1) * 1000.0} ms out bm\n"
            end

        end
    end
end
