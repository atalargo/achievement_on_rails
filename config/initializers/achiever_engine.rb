require 'AchieverEngine'

AchieverEngine.setup do |config|

    config.init_cache = false

    config.block_available_after_progress = true

    config.extra_behaviours_paths = nil
end
