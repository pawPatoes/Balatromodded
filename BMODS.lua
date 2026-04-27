local mod = SMODS.Mods["BMODS"]
-- read the files
local items_path = mod.path .. "lib/"
local item_files = NFS.getDirectoryItems(items_path)

--[[for _, file in ipairs(item_files) do
    if file:match("%.lua$") then
        local file_content = NFS.read(items_path .. file)
        local func, err = loadstring(file_content, file)
        if func then
            pcall(func)
            print("BMODS: Loaded " .. file)
        else
            print("Error loading " .. file .. ": " .. tostring(err))
            error(err)
        end
    end
end]]
SMODS.Atlas {
    key = "modicon",
    path = "modicon.png",
    px = 96,
    py = 96
}
-- scoring
function Card.scoring(self, context)
    if self.config.center and self.config.center.scoring then
        return self.config.center.scoring(self, context)
    end
end
-- adv remove
function Card.adv_remove_from_deck(self)
    if self.config.center and self.config.center.adv_remove_from_deck then
        self.config.center.adv_remove_from_deck(self.config.center, self)
    end
    if self.config.center and self.config.center.joker_buffs and self.config.center.joker_buffs.remove then
        self.config.center.joker_buffs.remove(self.config.center, self)
    end
end
-- joker calculation editing
local card_calc_joker_ref = Card.calculate_joker
function Card.calculate_joker(self, context)
    local ret = nil
    if context.other_joker == self and self.config.center.only_blueprint and context.blueprint then
        ret = self.config.center.only_blueprint(self, context)
    elseif context.joker_main then
        if self.config.center.scoring then
            ret = self:scoring(context)
        end
    end

    if not ret then 
        ret = card_calc_joker_ref(self, context) 
    end

    if ret then
        return self:BMODS_SCORE_CALC(ret)
    end

    return ret
end
-- joker_buffs
local add_to_deck_ref = Card.add_to_deck
function Card.add_to_deck(self, from_debuff)
    add_to_deck_ref(self, from_debuff)
    if self.config.center.joker_buffs and self.config.center.joker_buffs.apply then
        if not from_debuff and not self.debuff then
            self.config.center.joker_buffs.apply(self.config.center, self)
        end
    end
end

local set_debuff_ref = Card.set_debuff
function Card.set_debuff(self, debuff)
    local was_debuffed = self.debuff
    set_debuff_ref(self, debuff)
    if was_debuffed ~= self.debuff and self.config.center and self.config.center.joker_buffs then
        if self.debuff then
            if self.config.center.joker_buffs.remove then self.config.center.joker_buffs.remove(self.config.center, self) end
        else
            if self.config.center.joker_buffs.apply then self.config.center.joker_buffs.apply(self.config.center, self) end
        end
    end
end

local card_sell_ref = Card.sell
function Card.sell(self)
    if self.config.center and self.config.center.joker_buffs and self.config.center.joker_buffs.remove then
        self.config.center.joker_buffs.remove(self.config.center, self)
    end
    card_sell_ref(self)
end

local card_remove_ref = Card.remove
function Card.remove(self)
    if self.config.center and self.config.center.joker_buffs and self.config.center.joker_buffs.remove then
        self.config.center.joker_buffs.remove(self.config.center, self)
    end
    card_remove_ref(self)
end

BMODS_TRACKER = BMODS_TRACKER or {}
local game_update_ref = Game.update
function Game.update(self, dt)  
    game_update_ref(self, dt)  
    if G.STAGE == G.STAGES.RUN and G.jokers then  
        for card_id, data in pairs(BMODS_TRACKER) do  
            local exists = false  
            if G.jokers.cards then  
                for _, j in ipairs(G.jokers.cards) do  
                    if j == data.card_ptr then   
                        exists = true  
                        break   
                    end  
                end  
            end  
            if not exists and data.card_ptr and type(data.card_ptr) == 'table' and data.card_ptr.adv_remove_from_deck then  
                data.card_ptr:adv_remove_from_deck()  
                BMODS_TRACKER[card_id] = nil  
            elseif not exists then  
                BMODS_TRACKER[card_id] = nil  
            end  
        end  
    end  
end  
local card_set_ability_ref = Card.set_ability
function Card.set_ability(self, center, initial, delay_sprites)
    card_set_ability_ref(self, center, initial, delay_sprites)
    if G.STAGE == G.STAGES.RUN and center then
        if center.adv_remove_from_deck or center.joker_buffs then
            local card_id = tostring(self)
            BMODS_TRACKER[card_id] = {
                center = center,
                card_ptr = self
            }
            if center.joker_buffs and center.joker_buffs.apply and not initial and not self.debuff then
                center.joker_buffs.apply(center, self)
            end
        end
    end
end
-- score adding
function Card.BMODS_SCORE_CALC(self, logic)  
    if not logic or type(logic) ~= 'table' then return logic end  
      
    if logic.score or logic.Xscore or logic.Escore then  
        -- Single validation check  
        if not G.GAME or not G.GAME.hands or not G.GAME.last_hand_played or not G.GAME.hands[G.GAME.last_hand_played] then  
            return logic  
        end  
          
        local current_mult = G.GAME.hands[G.GAME.last_hand_played].mult or 1  
          
        if logic.score then  
            logic.chip_mod = (logic.chip_mod or 0) + (logic.score / current_mult)  
            logic.score = nil  
        end  
        if logic.Xscore then  
            logic.Xmult_mod = (logic.Xmult_mod or 0) + logic.Xscore  
            logic.Xscore = nil  
        end  
        if logic.Escore then  
            logic.Emult_mod = (logic.Emult_mod or 0) + logic.Escore  
            logic.Escore = nil  
        end  
        logic.colour = logic.colour or G.C.PURPLE  
    end  
  
    return logic  
end

--[[SMODS.Joker {
    key = 'bmods',
    loc_txt = { name = 'BMODS Tester', text = { 'Used to test BMODS, unobtainable' } },
    rarity = 4,
    cost = 10000,
    discovered = true,
    in_pool = function(self, card)
        return false
    end,
    joker_buffs = {
        apply = function(self, card)
            print('ohhh ma god')
        end,
        remove = function(self, card)
            print('ohh ma god 2')
        end
    },
    adv_remove_from_deck = function(self, card)
        print("REMOVED!!")
    end,
    scoring = function(self, card)
        return { Xscore = 1000, message = "FAH" }
    end,
    only_blueprint = function(self, card)
        return { Xmult = 2, message = "blueprinted" }
    end
}]]