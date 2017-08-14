# 21 Game
module Calculable
  def prompt(msg)
    puts ">> #{msg}"
  end

  def clear
    system "clear"
  end

  def total_value_arr
    cards.each_with_object([]) { |card, arr| arr << card[2] }
  end

  def total_value
    total_value_arr.inject(:+)
  end

  def indices_of_aces
    cards.each_with_index.each_with_object([]) do |(card, idx), arr|
      arr << idx if card[2] == 11
    end
  end

  def calculate_value
    total_score = total_value
    return total_score if total_score <= 21
    counter = 0
    total_card_values = total_value_arr.clone
    if !indices_of_aces.empty?
      while counter < indices_of_aces.length
        total_card_values[indices_of_aces[counter]] = 1
        break if total_card_values.inject(:+) <= 21
        counter += 1
      end
      total_card_values.inject(:+)
    else
      total_value
    end
  end

  def largest_hand_count(player, dealer)
    largest_number_cards = if player.cards.length > dealer.cards.length
                             player.cards.length
                           else
                             dealer.cards.length
                           end
    largest_number_cards
  end

  def bust?
    calculate_value > 21
  end
end

module Displayable
  include Calculable

  def display_welcome_message
    prompt "Welcome to 21!"
    puts
  end

  def display_goodbye_message
    prompt "Thanks for playing, bye!"
  end

  def display_cards
    puts "------------------------"
    cards.each do |card|
      prompt "#{card[0]} of #{card[1]}"
    end
    puts "------------------------"
  end

  def display_value
    prompt "with a total value of #{calculate_value}"
  end

  def display_cards_and_value
    clear
    display_cards
    display_value
  end

  def clear_and_display_final_chart
    clear
    prompt "Final holdings by Player and Dealer:"
    puts "Player" + " " * 14 + "Dealer"
    puts "-" * 28
  end

  def player_cards_strings(player)
    player.cards.each_with_object([]) do |card, arr|
      arr << "#{card[0]} of #{card[1]}"
    end
  end

  def dealer_cards_strings(dealer)
    dealer.cards.each_with_object([]) do |card, arr|
      arr << "#{card[0]} of #{card[1]}"
    end
  end

  def final_chart(player, dealer)
    player_cards = player_cards_strings(player)
    dealer_cards = dealer_cards_strings(dealer)
    largest_hand_count(player, dealer).times do |counter|
      player_cards[counter] = '' if player_cards[counter].nil?
      dealer_cards[counter] = '' if dealer_cards[counter].nil?
      p_c = player_cards[counter]
      d_c = dealer_cards[counter]
      puts p_c + " " * (20 - p_c.length) + d_c
    end
  end

  def display_final_values(player, dealer)
    p_v = player.calculate_value.to_s
    d_v = dealer.calculate_value.to_s
    puts "-" * 28
    puts p_v + " " * (20 - p_v.length) + d_v
  end

  def display_final_hands_and_values(player, dealer)
    clear_and_display_final_chart
    final_chart(player, dealer)
    display_final_values(player, dealer)
  end

  def display_busted_message(player, dealer)
    if player.bust?
      player.display_busted_message
    elsif dealer.bust?
      dealer.display_busted_message
    end
  end
end

class Deck
  attr_reader :deck

  # rubocop:disable Metrics/MethodLength
  def initialize
    @deck = [
      ["Ace", "Spades", 11],
      ["Two", "Spades", 2],
      ["Three", "Spades", 3],
      ["Four", "Spades", 4],
      ["Five", "Spades", 5],
      ["Six", "Spades", 6],
      ["Seven", "Spades", 7],
      ["Eight", "Spades", 8],
      ["Nine", "Spades", 9],
      ["Ten", "Spades", 10],
      ["Jack", "Spades", 10],
      ["Queen", "Spades", 10],
      ["King", "Spades", 10],

      ["Ace", "Hearts", 11],
      ["Two", "Hearts", 2],
      ["Three", "Hearts", 3],
      ["Four", "Hearts", 4],
      ["Five", "Hearts", 5],
      ["Six", "Hearts", 6],
      ["Seven", "Hearts", 7],
      ["Eight", "Hearts", 8],
      ["Nine", "Hearts", 9],
      ["Ten", "Hearts", 10],
      ["Jack", "Hearts", 10],
      ["Queen", "Hearts", 10],
      ["King", "Hearts", 10],

      ["Ace", "Clubs", 11],
      ["Two", "Clubs", 2],
      ["Three", "Clubs", 3],
      ["Four", "Clubs", 4],
      ["Five", "Clubs", 5],
      ["Six", "Clubs", 6],
      ["Seven", "Clubs", 7],
      ["Eight", "Clubs", 8],
      ["Nine", "Clubs", 9],
      ["Ten", "Clubs", 10],
      ["Jack", "Clubs", 10],
      ["Queen", "Clubs", 10],
      ["King", "Clubs", 10],

      ["Ace", "Diamonds", 11],
      ["Two", "Diamonds", 2],
      ["Three", "Diamonds", 3],
      ["Four", "Diamonds", 4],
      ["Five", "Diamonds", 5],
      ["Six", "Diamonds", 6],
      ["Seven", "Diamonds", 7],
      ["Eight", "Diamonds", 8],
      ["Nine", "Diamonds", 9],
      ["Ten", "Diamonds", 10],
      ["Jack", "Diamonds", 10],
      ["Queen", "Diamonds", 10],
      ["King", "Diamonds", 10]
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def deal
    deck.delete(deck.sample)
  end
end

class Player
  include Displayable

  attr_reader :cards

  def initialize
    @cards = []
  end

  def hit?
    prompt "Hit? (y/n)"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ['y', 'yes', 'n', 'no'].include?(answer)
      prompt "Invalid choice."
    end
    answer == 'y' || answer == 'yes' ? true : false
  end

  def display_cards
    prompt "You currently hold:"
    super
  end

  def display_busted_message
    prompt "You lose. You busted!"
  end
end

class Dealer
  include Displayable

  attr_reader :cards, :revealed_card

  def initialize
    @cards = []
    @revealed_card = nil
  end

  def reveal_card
    @revealed_card = cards.sample if revealed_card.nil?
    card = revealed_card[0]
    suit = revealed_card[1]
    value = revealed_card[2]
    prompt "Dealer holds #{card} of #{suit} with a value of #{value}"
  end

  def at_least_17?
    calculate_value >= 17
  end

  def display_cards
    prompt "Dealer holds:"
    super
  end

  def display_busted_message
    prompt "Dealer busted. You win!"
  end
end

class GameEngine
  include Displayable

  attr_reader :player, :dealer, :deck

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def initialize_game
    initialize
    deal
  end

  def play
    display_welcome_message
    loop do
      loop do
        initialize_game
        player_goes
        break if player.bust?

        dealer_goes
        break
      end
      display_final_hands_and_values(player, dealer)
      display_busted_message(player, dealer)
      determine_winner
      break unless play_again?
    end
    display_goodbye_message
  end

  def deal
    2.times do
      hit_player
      hit_dealer
    end
  end

  def hit_player
    player.cards << deck.deal
  end

  def hit_dealer
    dealer.cards << deck.deal
  end

  def player_goes
    loop do
      player.display_cards_and_value
      break if player.bust?
      dealer.reveal_card
      player.hit? ? hit_player : break
    end
  end

  def dealer_goes
    loop do
      hit_dealer
      break if dealer.at_least_17?
    end
  end

  def determine_winner
    return nil if player.bust? || dealer.bust?
    if player.calculate_value > dealer.calculate_value
      prompt "You win!"
    elsif player.calculate_value < dealer.calculate_value
      prompt "Dealer wins!"
    else
      prompt "Tie."
    end
  end

  def play_again?
    prompt "Would you like to play again? (y/n)"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ['y', 'yes', 'n', 'no'].include?(answer)
      prompt "Invalid choice."
    end
    answer == 'y' || answer == 'yes' ? true : false
  end
end

GameEngine.new.play
