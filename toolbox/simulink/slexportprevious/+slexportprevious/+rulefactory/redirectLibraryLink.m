function rule = redirectLibraryLink( srcLocation, dstLocation, identifyingRule )














R36
srcLocation( 1, : )char
dstLocation( 1, : )char
identifyingRule( 1, : )char = ''
end 

rule = [ '<Block<BlockType|"Reference">', identifyingRule, '<SourceBlock|"', srcLocation, '":repval "', dstLocation, '">>' ];

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpmDXbW6.p.
% Please follow local copyright laws when handling this file.

