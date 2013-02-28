
require 'db_ar_helper'

require './lib/AchieverEngine'
require './lib/AchieverEngine/models/achievement'
require './lib/AchieverEngine/models/achievement_relation'


class User
    def initialize(id)
        @id = id
    end

    def id
        @id
    end
end
