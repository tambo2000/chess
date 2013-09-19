# coding: utf-8

require 'colorize'

class Chess
  attr_reader :board
  attr_accessor :current_player

  def initialize
    @board = Board.new
    @current_player = :white
    @player_one = HumanPlayer.new
    @player_two = HumanPlayer.new
  end

  def play
    until @board.checkmate?(@current_player)

      moved_correctly = false
      until moved_correctly == true
        @board.display_board
        player_one_move = @player_one.get_move(@current_player)
        moved_correctly = @board.move_piece(player_one_move[0], player_one_move[1])
        if moved_correctly == false
          puts "Invalid move. Try again."
        end
      end

      @current_player = @current_player == :white ? :black : :white

    end
    @board.display_board
  end

end

class Board

  attr_accessor :grid

  def initialize
    @grid = []
    (0..7).each do |rank|
      @grid << []
      (0..7).each do |file|
       @grid[rank] << :empty
      end
    end

    Rook.new([0, 0], :black, self)
    Knight.new([0, 1], :black, self)
    Bishop.new([0, 2], :black, self)
    Queen.new([0, 3], :black, self)
    King.new([0, 4], :black, self)
    Bishop.new([0, 5], :black, self)
    Knight.new([0, 6], :black, self)
    Rook.new([0, 7], :black, self)

    (0..7).each do |rank1|
      Pawn.new([1, rank1], :black, self)
    end

    Rook.new([7, 0], :white, self)
    Knight.new([7, 1], :white, self)
    Bishop.new([7, 2], :white, self)
    Queen.new([7, 3], :white, self)
    King.new([7, 4], :white, self)
    Bishop.new([7, 5], :white, self)
    Knight.new([7, 6], :white, self)
    Rook.new([7, 7], :white, self)

    (0..7).each do |rank1|
      Pawn.new([6, rank1], :white, self)
    end

  end

  def in_check?(player_color)
    # get the same color king's location
    own_king_location = []
    @grid.each_with_index do |rank, rank_index|
      rank.each_with_index do |piece, file_index|
        next if piece == :empty
        if piece.color == player_color && piece.class == King
          own_king_location = [rank_index, file_index]
        end
      end
    end

    # check each opposite color piece and see if they can move to our king validly
    @grid.each_with_index do |rank, rank_index|
      rank.each_with_index do |piece, file_index|
        next if piece == :empty
        if piece.color != player_color &&
        piece.valid_move_without_in_check?([rank_index, file_index], own_king_location, self)
          # puts "#{player_color} is in check!"
          return true
        end
      end
    end

    false
  end

  def checkmate?(player_color)
    return false unless in_check?(player_color)
    @grid.each_with_index do |rank, rank_index|
      rank.each_with_index do |piece, file_index|
        next if piece == :empty
        if piece.color == player_color

          # go through each of player's pieces
          # go through each of piece's valid moves
          # check if board still in check after each move
          # if not, return true

          (0..7).each do |destination_rank|
            (0..7).each do |destination_file|
              dup_board = self.dup
              dup_board.move_piece([rank_index, file_index], [destination_rank, destination_file])
              #
              # p [rank_index, file_index]
              # p [destination_rank, destination_file]
              return false if !dup_board.in_check?(player_color)
            end
          end
        end
      end
    end
    p "#{player_color} is in checkmate!"
    true
  end

  def move_piece(start, destination)
    if tile_at(start) != :empty
      return tile_at(start).move(start, destination, self)
    else
      puts "The start space is empty!"
      return false
    end

  end

  def tile_at(pos)
    rank, file = pos
    @grid[rank][file]
  end

  def set_tile_at(pos, piece)
    rank, file = pos
    @grid[rank][file] = piece
  end

  def dup
    new_board = Board.new
    new_board.grid.each_with_index do |rank, rank_index|
      rank.each_with_index do |tile, file_index|
        if @grid[rank_index][file_index] != :empty
          new_board.grid[rank_index][file_index] = @grid[rank_index][file_index].dup
        else
          new_board.grid[rank_index][file_index] = :empty
        end
      end
    end
    new_board
  end

  def display_board
    pieces = { Rook => "♜",
               Bishop => "♝",
               Queen => "♛",
               Knight => "♞",
               Pawn => "♟",
               King => "♚"}

    puts "  a b c d e f g h"
    (0..7).each do |rank|
      print "#{8 - rank} "
      (0..7).each do |file|
        background = (rank + file) % 2 == 0 ? :yellow : :light_red
        piece = self.tile_at([rank, file])
        if piece != :empty
          print "#{pieces[piece.class]} ".colorize(:color => piece.color, :background => background)
        else
          print "  ".colorize(:background => background)
        end
      end
      print " #{8 - rank}"
      puts
    end
    puts "  a b c d e f g h"
    puts
  end

end

class Piece
  attr_reader :color

  def initialize(position, color, board)
    @color = color
    board.set_tile_at(position, self)
  end

  def move(start, destination, board)
    #check if valid move
    if valid_move?(start, destination, board)
      board.set_tile_at(start, :empty)
      board.set_tile_at(destination, self)
      return true
    end

    return false
  end

  def move_without_validation(start, destination, board)
    #check if valid move
      board.set_tile_at(start, :empty)
      board.set_tile_at(destination, self)
  end

  def valid_move?(start, destination, board)
    # not valid if off the board
    return false if destination.any? { |val| val < 0 || val > 7 }

    return false unless valid_move_without_in_check?(start, destination, board)

    if board.tile_at(destination) != :empty
      if board.tile_at(start).color == board.tile_at(destination).color
        return false # not valid if same color piece at destination
      elsif start == destination
        return false
      end
    else
      dup_board = board.dup
      if (board.tile_at(destination) == :empty ||
          (board.tile_at(destination).class != King &&
          board.tile_at(destination).color != board.tile_at(start).color))
        move_without_validation(start, destination, dup_board)
      end
      if dup_board.in_check?(@color)
        return false
      end
    end

    true
  end

  def valid_move_without_in_check?(start, destination, board)
    # not valid if off the board
    return false if destination.any? { |val| val < 0 || val > 7 }

    if board.tile_at(destination) != :empty
      if board.tile_at(start).color == board.tile_at(destination).color
        return false
        # not valid if same color piece at destination
      elsif start == destination
        return false
      end
    end
    true
  end

  def same_row?(start, destination)
    if start[0] == destination[0]
      return true
    end
    false
  end

  def same_column?(start, destination)
    if start[1] == destination[1]
      return true
    end
    false
  end

  def same_diagonal?(start, destination)
    if ((start[1].to_f - destination[1])/(start[0] - destination[0])).abs == 1.0
      return true
    end
    false
  end

  def return_low_high(num1, num2)
    if num1 < num2
      return [num1, num2]
    else
      return [num2, num1]
    end
  end

end

class Slider < Piece
  def initialize(position, color, board)
    super(position, color, board)
  end

  def valid_move_without_in_check?(start, destination, board)
    # false if invalid general move
    super(start, destination, board)
  end

  def valid_cardinal_move?(start, destination, board)
    # false if not in same row or column (non vertical or horizontal move)
    return false unless (same_row?(start, destination) ||
                        same_column?(start, destination))

    rank_low, rank_high = return_low_high(start[0], destination[0])
    file_low, file_high = return_low_high(start[1], destination[1])
    # if in same rank
    if same_column?(start, destination)
      # check each tile in between
      ((rank_low + 1)...rank_high).each do |index|
        # make sure there are no pieces in between
        return false if board.tile_at([index, start[1]]) != :empty
      end
    else # if in same file
      ((file_low + 1)...file_high).each do |index|
        return false if board.tile_at([start[0], index]) != :empty
      end
    end
    true
  end

  def valid_diagonal_move?(start, destination, board)
    # false if not in same diagonal
    return false unless same_diagonal?(start, destination)
    # makes sure space in between are empty
    i = 1
    while i < (start[0] - destination[0]).abs
      if start[0] < destination[0] && start[1] < destination[1]
        return false unless board.tile_at([start[0]+i, start[1]+i]) == :empty
      elsif start[0] < destination[0] && start[1] > destination[1]
        return false unless board.tile_at([start[0]+i, start[1]-i]) == :empty
      elsif start[0] > destination[0] && start[1] < destination[1]
        return false unless board.tile_at([start[0]-i, start[1]+i]) == :empty
      elsif start[0] > destination[0] && start[1] > destination[1]
        return false unless board.tile_at([start[0]-i, start[1]-i]) == :empty
      end
      i += 1
    end

    true
  end

end

class Rook < Slider
  def initialize(position, color, board)
    super(position, color, board)
  end

  def valid_move_without_in_check?(start, destination, board)
    # false if invalid general move
    return false unless super(start, destination, board)
    # false if not in same row or column (non vertical or horizontal move)
    return valid_cardinal_move?(start, destination, board)
  end

end

class Bishop < Slider
  def initialize(position, color, board)
    super(position, color, board)
  end

  def valid_move_without_in_check?(start, destination, board)
    # false if invalid general move

    return false unless super(start, destination, board)
    # false if not in same diagonal

    return valid_diagonal_move?(start, destination, board)
  end

end

class Queen < Slider
  def initialize(position, color, board)
    super(position, color, board)
  end

  def valid_move_without_in_check?(start, destination, board)
    # false if invalid general move

    return false unless super(start, destination, board)
    # false if not in same diagonal
    return (valid_diagonal_move?(start, destination, board) ||
           valid_cardinal_move?(start, destination, board))
  end
end

class Knight < Piece
  def initialize(position, color, board)
    super(position, color, board)
  end

  def valid_move_without_in_check?(start, destination, board)
    # false if invalid general move
    return false unless super(start, destination, board)

    valid_moves = [1, 2, -1, -2]
    possible_spaces = []
    valid_moves.each do |move_horizontal|
      valid_moves.each do |move_vertical|
        next if move_horizontal.abs == move_vertical.abs
        possible_spaces << [(start[0] + move_horizontal), (start[1] + move_vertical)]
      end
    end

    possible_spaces.include?(destination)
  end

end

class Pawn < Piece
  def initialize(position, color, board)
    super(position, color, board)
  end

  def valid_move_without_in_check?(start, destination, board)
    # false if invalid general move
    return false unless super(start, destination, board)

    pawn = board.tile_at(start)

    # pawn can never go backwards
    if ((start[0] - destination[0] < 0 && pawn.color == :white) ||
        (start[0] - destination[0] > 0 && pawn.color == :black))
        return false
    end

    if start[0] == destination[0]
      return false
    end

    # if pawn can capture then diagonal move allowed
    if ((start[0] - destination[0]).abs == 1 &&
       (start[1] - destination[1]).abs == 1 &&
       board.tile_at(destination) != :empty &&
       board.tile_at(destination).color != pawn.color)
       return true
    # pawn can move one space forward
    elsif ((start[0] - destination[0] == -1 &&
            pawn.color == :black &&
            board.tile_at(destination) == :empty) ||
           (start[0] - destination[0] == 1 &&
            pawn.color == :white &&
            board.tile_at(destination) == :empty) ||
        # if pawn is in starting row, then first move for pawn can be 1 or 2 spaces
           (start[0] == 6 && destination[0] == 4 &&
            pawn.color == :white && board.tile_at(destination) == :empty) ||
           (start[0] == 1 && destination[0] == 3 &&
            pawn.color == :black && board.tile_at(destination) == :empty))
      return same_column?(start, destination)
    end

  end
end

class King < Piece
  def initialize(position, color, board)
    super(position, color, board)
  end

  def valid_move_without_in_check?(start, destination, board)
    return false unless super(start, destination, board)

    return false if ((start[0] - destination[0]).abs > 1 ||
                        (start[1] - destination[1]).abs > 1)
    true
  end

end


class HumanPlayer

  # def initialize(color)
#     @color = color
#   end

  def get_move(color)
    puts "#{color} player, Which piece would you like to move?"
    start_location = convert_user_input_to_location(gets.chomp)

    puts "#{color} player, Where would you like to move this piece?"
    end_location = convert_user_input_to_location(gets.chomp)

    [start_location, end_location]
  end

  def convert_user_input_to_location(user_input)
    file_translate = { "a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4,
                        "f" => 5, "g" => 6, "h" => 7 }
    location = [0,0]

    location[0] = (8 - user_input.scan(/\d/).first.to_i)
    location[1] = file_translate[user_input.scan(/[a-h]|[A-H]/).first.downcase]

    location
  end

end


a = Chess.new
a.play
