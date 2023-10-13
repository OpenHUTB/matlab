function fqStruct = extractLevel( fqStruct, level )

arguments
fqStruct
level( 1, 1 ){ mustBeInteger, mustBeGreaterThan( level, 0 ) }
end 

fqStruct = fqStruct( level, : );
end 



