# coding: utf-8

require 'colorize'




class Checkers


end






class Board

	def initialize
		@pieces = []
		make_starting_grid
		p @pieces
	end

	def make_starting_grid
		create_starting_pieces(:red)
		create_starting_pieces(:white)
	end

	def create_starting_pieces(color)
		row_offset = ((color == :red) ? 0 : 5) 
		(0..3).each do |row|
			(0..7).each do |column|
				if (row_offset + row + column) % 2 == 1
					@pieces << Man.new([row, column], color)
				end
			end
		end
	end

end





class Piece
	def initialize(position, color)
		@position, @color = position, color
	end
end



class King < Piece
	def initalize(position, color)
		super(position, color)
	end
end




class Man < King
	def initalize(position, color)
		super(position, color)
	end
end