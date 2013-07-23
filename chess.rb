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

end

class Piece
  attr_reader :color

  def initialize(position, color, board)
    rank, file = position
    @color = color
    board.grid[rank][file] = self
  end

  def move(start, destination, board)
    #check if valid move
    start_rank, start_file = start
    destination_rank, destination_file = destination
    board.grid[start_rank][start_file] = :empty
    board.grid[destination_rank][destination_file] = self
  end

  def valid_move? (start, destination, board)
    # if board.tile_at()
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
a.move_piece([0,0], [3,3])