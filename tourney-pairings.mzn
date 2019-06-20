include "globals.mzn";

/* Parameters */

int: number_of_players;
constraint
    assert(
        number_of_players mod 2 == 0,
        "Need an even number of players"
    );
set of int: RANK = 1..number_of_players;
array[RANK] of string: player_name;
array[RANK] of bool: player_competitive;
constraint
    assert(
        sum (p in RANK) (
            player_competitive[p]
        )
        ==
        number_of_players div 2,
        "Need equal number of competitive and casual players"
    );
array[RANK, RANK] of bool: friends;
int: competitive_satisfaction_factor;
int: max_satisfaction = number_of_players * number_of_players;
set of int: SATISFACTION = 0..max_satisfaction;


/* Decisions */

array[RANK] of var RANK: partner;


/* Objective */

/*
 * Every player derives some amount of satisfaction.
 * The goal is to maximize the overall satisfaction.
 *
 * A competitive player's satisfaction comes from
 * being paired with one of her friends.
 *
 * A casual player's satisfaction comes from the
 * relative strength of the other pairings.
 */
array[RANK] of var SATISFACTION: satisfaction;
constraint
    forall (p in RANK) (
        satisfaction[p]
        ==
        (
            player_competitive[p]
            *
            competitive_satisfaction_factor
            *
            friends[p, partner[p]]
        )
        +
        (
            (1 - player_competitive[p])
            *
            sum (o in RANK where o != p) (
                o + partner[o]
            )
            div
            2
        )
    );

var int: obj =
    sum (p in RANK) (
        satisfaction[p]
    );

solve
    :: seq_search([
        int_search(partner, dom_w_deg, indomain_median, complete),
        int_search(satisfaction, dom_w_deg, indomain_max, complete)
    ])
    :: restart_luby(250)
maximize obj;


/* Constraints */

% No one partners with themselves.
constraint
    forall (p in RANK) (
        partner[p] != p
    );

% No two players have the same partner.
constraint
    alldifferent(partner);

% Partnership is symmetric.
constraint
    inverse(partner, partner);


/* Output */

output(
    [
        "Player \(player_name[p]),"
        ++ " ranked #\(p) "
        ++ " partners with player \(player_name[fix(partner[p])])"
        ++ " ranked #\(fix(partner[p]))"
        ++ ": satisfaction \(fix(satisfaction[p]))\n"
        | p in RANK
    ]
    ++
    ["satisfaction = \(obj)\n"]
);
