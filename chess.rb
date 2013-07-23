# coding: utf-8

require 'colorize'

class Chess

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

  def move_piece(start, destination)
    if tile_at(start) != :empty
      tile_at(start).move(start, destination, self)
    else
      puts "The start space is empty!"
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

  def display_board
    pieces = { Rook => "♜",
               Bishop => "♝",
               Queen => "♛",
               Knight => "♞",
               Pawn => "♟",
               King => "♚"}

    (0..7).each do |rank|
      (0..7).each do |file|
        background = (rank + file) % 2 == 0 ? :yellow : :light_red
        piece = self.tile_at([rank, file])
        if piece != :empty
          print "#{pieces[piece.class]} ".colorize(:color => piece.color, :background => background)
        else
          print "  ".colorize(:background => background)
        end
      end
      puts
    end

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
    end
  end

  def valid_move?(start, destination, board)
    return false if destination.any? { |val| val < 0 || val > 7 }
    if board.tile_at(destination) != :empty
      if board.tile_at(start).color == board.tile_at(destination).color
        return false
      elsif board.tile_at(destination).class == King
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
    if ((start[1] - destination[1])/(start[0] - destination[0])).abs == 1
      return true
    end
    false
  end

end

class Slider < Piece
  def initialize(position, color, board)
    super(position, color, board)
  end

end

class Rook < Slider
  def initialize(position, color, board)
    super(position, color, board)
  end

  def valid_move?(start, destination, board)
    # false if invalid general move
    return false unless super(start, destination, board)
    # false if not in same row or column (non vertical or horizontal move)
    return false unless same_row?(start, destination) || same_column?(start, destination)
    # if in same rank
    if same_row?(start, destination)
      # check each tile in between
      ((start[1] + 1)...destination[1]).each do |index|
        # make sure there are no pieces in between
        return false if board.tile_at([start[0], index]) != :empty
      end
    else # if in same file
      ((start[0] + 1)...destination[0]).each do |index|
        return false if board.tile_at([index, start[1]]) != :empty
      end
    end

    true
  end

end

class Bishop < Slider
  def initialize(position, color, board)
    super(position, color, board)
  end
end

class Queen < Slider
  def initialize(position, color, board)
    super(position, color, board)
  end
end

class Knight < Piece
  def initialize(position, color, board)
    super(position, color, board)
  end
end

class Pawn < Piece
  def initialize(position, color, board)
    super(position, color, board)
  end

  def valid_move?(start, destination, board)
    # false if invalid general move
    return false unless super(start, destination, board)
    # if pawn is in starting row, then first move for pawn
    if ((start[1] - destination[1] == -1 && board.tile_at(start).color == :black) ||
        (start[1] - destination[1] == 1 && board.tile_at(start).color == :white) ||
        (start[0] == 6 && destination[0] == 4 && board.tile_at(start).color) ||
        (start[0] == 1 && destination[0] == 3 && board.tile_at(start).color))
       return same_row?(start, destination)
    end
  end
end

class King < Piece
  def initialize(position, color, board)
    super(position, color, board)
  end
end


a = Board.new
a.move_piece([1, 0], [2, 0])
a.display_board
p a.grid