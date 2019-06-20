#!/usr/bin/env python

import random as rnd


number_of_players = 40
friends = [[None] * number_of_players for i in range(number_of_players)]

for i in range(number_of_players):
    for j in range(i, number_of_players):
        if i == j:
            friends[i][j] = True
        else:
            friends[i][j] = friends[j][i] = (
                rnd.random()
                <
                0.3 * (number_of_players - (j - i)) / float(number_of_players) 
            )
print('[', end='')
for i in range(number_of_players):
    print('|' + ', '.join(map(lambda f: str(f).lower(), friends[i])))
print('|]')

    
