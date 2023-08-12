function blockParam = setBlockParam( block, varargin )






p = inputParser;
blkParam = block.blkParam;
for i = 1:length( blkParam.required )
p.addParamValue( blkParam.required{ i }, '' )
end 

for i = 1:length( blkParam.optional )
p.addOptional( blkParam.optional{ i } )
end 

p.parse( varargin{ : } );
blockParam = p.Results;

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp5_02fJ.p.
% Please follow local copyright laws when handling this file.

