function slPromoteParameter( aParentPath, aBlockPath, aParameterName )



try 
if ~isempty( aParentPath ) && ~isempty( aBlockPath ) && ~isempty( aParameterName )
i_PromoteToParent( aParentPath, aBlockPath, aParameterName );
end 
catch exp
errordlg( exp.message );
end 

function i_PromoteToParent( aParentPath, aBlockPath, aParameterName )
aMaskObj = Simulink.Mask.get( aParentPath );
if isempty( aMaskObj )
aMaskObj = Simulink.Mask.create( aParentPath );
end 

aBlockRelativePath = strrep( aBlockPath, [ aParentPath, '/' ], '' );
aMaskObj.addParameter( 'Type', 'promote', 'TypeOptions', { [ aBlockRelativePath, '/', aParameterName ] }, 'Name', aParameterName, 'Prompt', [ aParameterName, ':' ] );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZAtM26.p.
% Please follow local copyright laws when handling this file.

