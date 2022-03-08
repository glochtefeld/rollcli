#!/usr/bin/raku
use v6;

class Die {
    has $.count;
    has $.size;
    method roll() { max($.count, ($.size * $.count).rand.Int); }
}

sub mk-roll ($str) {
    if $str ~~ /^(d|\d+d)/ {
        (my $ct, my $sz) = $str.split('d');
        $ct = 1 if $ct eq "";
        return Die.new(count=>$ct.Int, size=>$sz.Int).roll();
    }
    elsif $str ~~ /\d+/ { return $str.Int; }
    else { return $str; }
}

multi sub sumRoll(@arr, $acc where @arr.elems == 0) { $acc; }
multi sub sumRoll(@arr, $acc) {
    if @arr[0] eq '-' {
        return sumRoll(@arr[2..*],$acc + @arr[1] * -1);
    }
    else {
        return sumRoll(@arr[1..*], $acc + @arr[0]);
    }
}
multi sub sumRoll(@arr) { sumRoll(@arr, 0); }

#`[
    sumRoll([],acc) = acc
    sumRoll(h::n::t, acc) = if h eq '-' then sumRoll(t, acc-n) else sumRoll(n::t, acc+h)
]

sub parse-roll($roll) { # 2d6+8-2 -> 2d6, 8, -, 2 -> <roll> 8, -, 2 -> <sum>
    sumRoll($roll.split(/\+|\-/, :v).map({$_.Str unless $_ eq '+'}).map(&mk-roll));
}

constant @suits = <Clubs Diamonds Hearts Spades>;
constant @t-suits = <Wands Cups Swords Pentacles Major>;
constant @major-arcana = 'The Fool', 'The Magician', 'The High Priestess', 'The Empress', 'The Emperor', 'The Hierophant', 'The Lovers', 'The Chariot', 'Strength', 'The Hermit', 'Wheel of Fortune', 'Justice', 'The Hanged Man', 'Death', 'Temperance', 'The Devil', 'The Tower', 'The Star', 'The Moon', 'The Sun', 'Judgement', 'The World';
constant @vals = <Ace 2 3 4 5 6 7 8 9 10 Jack Queen King>;

class Card {
    has $.suit;
    has $.value;
    has Bool $.isMajor;
}

class Deck {
    has @!suits;
    has %!drawn-cards;
    
    submethod BUILD( :@suits ) {
        @!suits = @suits;
        %!drawn-cards = @suits.map({$_=>SetHash.new}).hash;
    }

    method shuffle() { %!drawn-cards = @suits.map({$_=>SetHash.new}).hash; }
    method draw() {
        my $s = @!suits.roll();
        my @all = @vals;
        my $mj = False;
        if $s eq 'Major' {
            @all = @major-arcana;
            $mj = True;
        }
        my $val = (@all ∖ %!drawn-cards{$s}).roll();
        %!drawn-cards{$s}.set($val);
        Card.new(suit=>$s,value=>$val,isMajor=>$mj);
    }
}

my Deck $tarot = Deck.new(suits=>@t-suits);
my Deck $standard = Deck.new(suits=>@suits);

sub MAIN() {
    say 'Welcome to the all-purpose die roller/card drawer. Type CTRL-D to exit.';
    my $in = prompt "1. Roll dice\n2. Draw a card\n3.Re-shuffle the deck\n[1] [2] [3]: ";
    exit if $in ~~ Any:U;
    repeat {
        if $in eq '1' {
            my $roll = prompt "Type out your die roll without spaces, e.g. XXdYY+ZZ: ";
            my $res = parse-roll($roll);
            say "Result: $res";
        }
        elsif $in eq '2' {
            my $deck = prompt "1. Standard Deck\n2. Tarot Deck\n[1] [2]: ";
            if $deck eq '1' { $standard.draw().say; }
            elsif $deck eq '2' { $tarot.draw().say; }
            else { say "We don't have that deck."; }
        }
        elsif $in eq '3' {
            my $deck = prompt "1. Standard Deck\n2. Tarot Deck\n[1] [2]: ";
            if $deck eq '1' { $standard.shuffle(); say "Shuffled."; }
            elsif $deck eq '2' { $tarot.shuffle(); say "Shuffled."; }
            else { say "We don't have that deck."; }
        }
        $in = prompt "1. Roll dice\n2. Draw a card\n3.Re-shuffle the deck\n[1] [2] [3]: ";
        exit(0) if $in ~~ Any:U;
    } while True;
    
}
