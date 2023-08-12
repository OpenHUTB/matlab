function [ updatedBlockDiagrams, updatedBlocks ] = slConfigureVariantGPC( systemName, mode )










































narginchk( 2, 2 );


load_system( systemName );

top = bdroot( systemName );

topGPC = get_param( top, 'GeneratePreprocessorConditionals' );

if strcmpi( mode, 'Enable all' )
gpc = 'on';
elseif strcmpi( mode, 'Disable all' )
gpc = 'off';
else 
error( '2nd argument, mode, must be ''Enable all'' or ''Disable all''' );
end 

blockDiagrams = containers.Map(  );
blockDiagrams( systemName ) = 1;
updatedBlockDiagrams = containers.Map(  );



if ~isequal( topGPC, 'Use local settings' ) && isequal( top, systemName )
updatedBlockDiagrams( systemName ) = 1;
disp( [ 'Disabling ''Generate preprocessor conditionals'' warning for ', systemName ] );
configObj = getActiveConfigSet( systemName );

if isa( configObj, 'Simulink.ConfigSet' )
set_param( systemName, 'GeneratePreprocessorConditionals', 'Use local settings' );
elseif isa( configObj, 'Simulink.ConfigSetRef' )


configRefObj = configObj.getRefConfigSet;
set_param( configRefObj, 'GeneratePreprocessorConditionals', 'Use local settings' );
end 

end 

[ ~, variantBlocks ] = slFindVariantBlocks( systemName );

updatedBlocks = {  };
for i = 1:length( variantBlocks )
vBlock = variantBlocks{ i };
idx = strfind( vBlock, '/' );
bd = vBlock( 1:idx( 1 ) - 1 );
if ~blockDiagrams.isKey( bd )
load_system( bd );
blockDiagrams( bd ) = 1;
end 

currentValue = get_param( vBlock, 'GeneratePreprocessorConditionals' );
if ~isequal( currentValue, gpc )
if ~updatedBlockDiagrams.isKey( bd )
bdType = get_param( bd, 'BlockDiagramType' );
if isequal( bdType, 'library' )
set_param( bd, 'Lock', 'off' )
end 
updatedBlockDiagrams( bd ) = 1;
end 
updatedBlocks{ end  + 1, 1 } = vBlock;%#ok
set_param( vBlock, 'GeneratePreprocessorConditionals', gpc );
end 
end 

updatedBlockDiagrams = unique( updatedBlockDiagrams.keys );

updatedBlockDiagrams = updatedBlockDiagrams';

if nargout == 0
if ~isempty( updatedBlocks )
disp( 'Updated Block(s):' );
disp( updatedBlocks );
end 

if ~isempty( updatedBlockDiagrams )
disp( 'Please save your model(s):' );
disp( updatedBlockDiagrams );
end 
clear updatedBlockDiagrams updatedBlocks;
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpbI0sl8.p.
% Please follow local copyright laws when handling this file.

