function internalAddBlockDiagramHistoryCallback( bd )








obj = get_param( bd, 'Object' );
if ~obj.hasCallback( 'PreShow', 'SimulinkHistoryCallback' )
Simulink.addBlockDiagramCallback( bd, 'PreShow',  ...
'SimulinkHistoryCallback', @i_PreShowHistoryCallback );
end 

if ~obj.hasCallback( 'PostSave', 'SimulinkHistoryCallback' )
Simulink.addBlockDiagramCallback( bd, 'PostSave',  ...
'SimulinkHistoryCallback', @i_PostSaveHistoryCallback );
end 

end 

function okToAdd = i_checkBeforeAdd( bdroot )
[ ~, ~, ext ] = fileparts( get_param( bdroot, 'Filename' ) );

okToAdd =  ...
bdIsLoaded( bdroot ) ...
 && ~slhistory.exclude.get( get_param( bdroot, 'Handle' ) ) ...
 && any( strcmpi( ext, { '.slx', '.mdl' } ) );
end 

function i_PreShowHistoryCallback(  )


if i_checkBeforeAdd( bdroot ) ...
 && ~isempty( get_param( bdroot, 'FileName' ) )
slhistory.add( get_param( bdroot, 'FileName' ) );
end 
end 

function i_PostSaveHistoryCallback(  )

if i_checkBeforeAdd( bdroot ) ...
 && strcmp( get_param( bdroot, 'Open' ), 'on' )
slhistory.add( get_param( bdroot, 'FileName' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpojVHNa.p.
% Please follow local copyright laws when handling this file.

