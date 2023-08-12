function validateBlockName( blockName )




if isstring( blockName ) && isscalar( blockName )
blockName = char( blockName );
end 

if isstring( blockName ) && ~isscalar( blockName )
blockName = cellstr( blockName );
end 

if ~ischar( blockName ) && ~iscellstr( blockName )
DAStudio.error( 'sl_inputmap:inputmap:inportMapBlockNameValue' );
end 

if iscellstr( blockName )

uniqueBlkNames = unique( blockName );
if length( uniqueBlkNames ) ~= length( blockName )
DAStudio.error( 'sl_inputmap:inputmap:inportMapBlockNameValue' );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpEF04p8.p.
% Please follow local copyright laws when handling this file.

