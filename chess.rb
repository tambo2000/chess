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

    p @grid
  end

  def move_piece(start, destination)
    if tile_at(start) != :empty
      tile_at(start).move(start, destination, self)
    else
      puts "The start space is empty!"
    end

    p @grid
  end

  def tile_at(pos)
    rank, file = pos
    @grid[rank][file]
  end

  def set_tile_at(pos, piece)
    rank, file = pos
    @grid[rank][file] = piece
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
    return false unless start[0] == destination[0] || start[1] == destination[1]
    # if in same rank
    if start[0] == destination[0]
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
end

class King < Piece
  def initialize(position, color, board)
    super(position, color, board)
  end
end


a = Board.new
a.move_piece([0, 0], [2, 0])