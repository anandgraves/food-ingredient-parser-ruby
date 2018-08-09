# Food ingredient parser

[![Gem Version](https://badge.fury.io/rb/food_ingredient_parser.svg)](https://rubygems.org/gems/food_ingredient_parser)

Ingredients are listed on food products in various ways. This [Ruby](https://www.ruby-lang.org/)
gem and program parses the ingredient text and returns a structured representation.

## Installation

```
gem install food_ingredient_parser
```

This will also install the dependency [treetop](http://cjheath.github.io/treetop).
If you want colored output for the test program, also install [pry](http://pryrepl.org/): `gem install pry`.

## Example

```ruby
require 'food_ingredient_parser'

s = "Water* 60%, suiker 30%, voedingszuren: citroenzuur, appelzuur, zuurteregelaar: E576/E577, " \
    + "natuurlijke citroen-limoen aroma's 0,2%, zoetstof: steviolglycosiden, * = Biologisch. " \
    + "E = door de E.U. goedgekeurde toevoeging."
parser = FoodIngredientParser::Parser.new
puts parser.parse(s).to_h.inspect
```
Results in
```
{
  :contains=>[
    {:name=>"Water", :amount=>"60%", :mark=>"*"},
    {:name=>"suiker", :amount=>"30%"},
    {:name=>"voedingszuren", :contains=>[
      {:name=>"citroenzuur"}
    ]},
    {:name=>"appelzuur"},
    {:name=>"zuurteregelaar", :contains=>[
      {:name=>"E576"},
      {:name=>"E577"}
    ]},
    {:name=>"natuurlijke citroen-limoen aroma's", :amount=>"0,2%"},
    {:name=>"zoetstof", :contains=>[
      {:name=>"steviolglycosiden"}
    ]}
  ],
  :notes=>[
    "* = Biologisch",
    "E = door de E.U. goedgekeurde toevoeging"
  ]
}
```

## Test tool

The executable `food_ingredient_parser` is available after installing the gem. If you're
running this from the source tree, use `bin/food_ingredient_parser` instead.

```
$ food_ingredient_parser -h
Usage: food_ingredient_parser [options] --file|-f <filename>
       food_ingredient_parser [options] --string|-s <ingredients>

    -f, --file FILE                  Parse all lines of the file as ingredient lists.
    -s, --string INGREDIENTS         Parse specified ingredient list.
    -q, --[no-]quiet                 Only show summary.
    -p, --parsed                     Only show lines that were successfully parsed.
    -e, --escape                     Escape newlines
    -c, --[no-]color                 Use color
    -n, --noresult                   Only show lines that had no result.
    -v, --[no-]verbose               Show more data (parsed tree).
        --version                    Show program version.
    -h, --help                       Show this help

$ food_ingredient_parser -v -s "tomato"
"tomato"
RootNode+Root3 offset=0, "tomato" (contains,notes):
  SyntaxNode offset=0, ""
  SyntaxNode offset=0, ""
  SyntaxNode offset=0, ""
  ListNode+List13 offset=0, "tomato" (contains):
    SyntaxNode+List12 offset=0, "tomato" (ingredient):
      SyntaxNode+Ingredient0 offset=0, "tomato":
        SyntaxNode offset=0, ""
        IngredientNode+IngredientSimpleWithAmount3 offset=0, "tomato" (ing):
          IngredientNode+IngredientSimple5 offset=0, "tomato" (name):
            SyntaxNode+IngredientSimple4 offset=0, "tomato" (word):
              SyntaxNode offset=0, "tomato":
                SyntaxNode offset=0, "t"
                SyntaxNode offset=1, "o"
                SyntaxNode offset=2, "m"
                SyntaxNode offset=3, "a"
                SyntaxNode offset=4, "t"
                SyntaxNode offset=5, "o"
              SyntaxNode offset=6, ""
        SyntaxNode offset=6, ""
      SyntaxNode offset=6, ""
  SyntaxNode+Root2 offset=6, "":
    SyntaxNode offset=6, ""
    SyntaxNode offset=6, ""
    SyntaxNode offset=6, ""
  SyntaxNode offset=6, ""
{:contains=>[{:name=>"tomato"}]}

$ food_ingredient_parser -q -f data/test-cases
parsed 35 (100.0%), no result 0 (0.0%)
```

If you want to use the output in (shell)scripts, the options `-e -c` may be quite useful.

## Test data

[`data/ingredient-samples-nl`](data/ingredient-samples-nl) contains about 150k
real-world ingredient lists found on the Dutch market. Each line contains one ingredient
list (newlines are encoded as `\n`, empty lines and those starting with `#` are ignored).
Currently almost three quarter is recognized and parsed. We aim to reach at least 90%.

