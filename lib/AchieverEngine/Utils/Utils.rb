
module AchieverEngine
    module Utils
        autoload :Nanoc, File.dirname(File.expand_path(__FILE__))+'/Nanoc/dgraph'

        class DirectedGraph < AchieverEngine::Utils::Nanoc::DirectedGraph
        end
    end
end
