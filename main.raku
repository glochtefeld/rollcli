#!/usr/bin/raku
use v6;

sub parse-roll($roll) { # In the form 2d6+2
    (my $count, my $die, my $bonus) = $roll.split('+').map({$_.split('d').map({Int($_)})}).flat;
    $bonus = 0 if $bonus ~~Any:U;    
    max($count, ($die × $count).rand.Int) + $bonus;
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
