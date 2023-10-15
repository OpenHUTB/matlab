function rule = redirectLibraryLink( srcLocation, dstLocation, identifyingRule )

arguments
srcLocation( 1, : )char
dstLocation( 1, : )char
identifyingRule( 1, : )char = ''
end 

rule = [ '<Block<BlockType|"Reference">', identifyingRule, '<SourceBlock|"', srcLocation, '":repval "', dstLocation, '">>' ];

end 
