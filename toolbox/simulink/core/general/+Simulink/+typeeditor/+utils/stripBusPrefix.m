function dataTypeStr = stripBusPrefix( dataType )




R36
dataType{ mustBeText }
end 

pat = "Bus: " | "bus: ";
dataTypeStr = extractAfter( dataType, pat );
if ~iscell( dataType ) && ~( isstring( dataType ) && numel( dataType ) > 1 )
if isempty( dataTypeStr ) || ismissing( string( dataTypeStr ) )
dataTypeStr = dataType;
end 
else 
for i = 1:numel( dataTypeStr )
if isempty( dataTypeStr{ i } ) || ismissing( string( dataTypeStr{ i } ) )
dataTypeStr{ i } = dataType{ i };
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmphBGf5j.p.
% Please follow local copyright laws when handling this file.

