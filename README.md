# iOSCalculator
A calculator application for iOS with mathematical expression evaluation.

## Implementation details

The input expression is first tokenized using regular expressions, in order to obtain a vector of tokens containing mathematical symbols.
Each element of such vector is then substituted with a symbol of its corrisponding class (e.g. 1 -> num or sin -> fun) and the acceptability of the expression is verified through a Push Down Automata.

The automata is structured as follows:

<img src="https://github.com/LorenzoNorcini/iOSCalculator/blob/master/Calculator/PDA.png" width="400">

Once the expression has been accepted it gets converted from standard infix notation to postfix notation (also known as Reverse Polish Notation). For example "((3+4)/2)*(5/2+1)" is converted to "3, 4, +, 2, /, 5, 2, /, 1, +, *".
This conversion is done through [Dijkstra's Shunting Yard](https://en.wikipedia.org/wiki/Shunting-yard_algorithm) algorithm.

## Screenshots

<div style="display: inline block;">
<img src="https://github.com/LorenzoNorcini/iOSCalculator/blob/master/Calculator/1.png" width="200">
<img src="https://github.com/LorenzoNorcini/iOSCalculator/blob/master/Calculator/2.png" width="200">
</div>
<div style="display: inline block;">
<img src="https://github.com/LorenzoNorcini/iOSCalculator/blob/master/Calculator/3.png" width="200">
<img src="https://github.com/LorenzoNorcini/iOSCalculator/blob/master/Calculator/4.png" width="200">
</div>
