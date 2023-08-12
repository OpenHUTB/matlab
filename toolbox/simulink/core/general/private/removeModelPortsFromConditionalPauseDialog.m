function removeModelPortsFromConditionalPauseDialog( modelH )







portConditionalPauseDialogObjectMap =  ...
SLStudio.GetAddConditionalPauseDialogPortMap(  );

allPortHandles = portConditionalPauseDialogObjectMap.keys(  );
for ndx = 1:portConditionalPauseDialogObjectMap.size
dlg = portConditionalPauseDialogObjectMap( allPortHandles{ ndx } );
if ( isequal( dlg.modelHandle, modelH ) )
dlg.deleteDialog;
portConditionalPauseDialogObjectMap.remove( allPortHandles{ ndx } );
end 
end 



blockConditionalPauseDialogObjectMap =  ...
SLStudio.GetBlockConditionalPauseDialogMap(  );
allBlockHandles = blockConditionalPauseDialogObjectMap.keys(  );
for ndx = 1:blockConditionalPauseDialogObjectMap.size
dlg = blockConditionalPauseDialogObjectMap( allBlockHandles{ ndx } );
if ( isequal( dlg.modelHandle, modelH ) )
dlg.deleteDialog;
blockConditionalPauseDialogObjectMap.remove( allPortHandles{ ndx } );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpK85RD8.p.
% Please follow local copyright laws when handling this file.

