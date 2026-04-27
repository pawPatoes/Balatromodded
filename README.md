# Balatromodded
READ HERE: https://raw.githubusercontent.com/pawPatoes/Balatromodded/refs/heads/main/README.md      
ALPHA!!! Adds features into Steamodded to make your life easier
Scoring:
USAGE:
Smods.something {
scoring = function(peramiters here)
code here
end
}
scoring = context.joker_main shortcut

only_blueprint
USAGE:
Smods.something {
only_blueprint = function(peramiters here)
code here
end
}
only_blueprint = only triggers when blueprint is copying your joker, (only triggers when OG joker triggers while being copied)

SCORE CALC
USAGE:
Smods.something {
anything that can return a value = function(peramiters here)
return {
score = num OR
Xscore = num OR
Escore = num
end
}
changes chips/mult to add that much to the total score whilst joker is triggered
EG: 15 x 1, score = 10 turns it into 25 x 1
EG: 100 x 10, Xscore = 2 turns it into 100 X 20

adv_remove_from_deck
USAGE:
Smods.something {
adv_remove_from_deck = function(peramiters)
code
end
}
advanced ver of remove_from_deck that is more precise (triggers when the joker is no longer in possesion via update)

joker_buffs
USAGE:
SMODS.something {
joker_buffs = {
        apply = function(self, card)
            code
        end,
        remove = function(self, card)
            code
        end
    }
}
apply runs when joker add_to_deck
remove runs when joker leaves

IN EXTREME ALPHA!
