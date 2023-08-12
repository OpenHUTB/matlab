function removePortFromConditionalPauseDialog( portH )





portConditionalPauseDialogObjectMap =  ...
SLStudio.GetAddConditionalPauseDialogPortMap(  );

if portConditionalPauseDialogObjectMap.isKey( portH )
dlg = portConditionalPauseDialogObjectMap( portH );
dlg.deleteDialog;
portConditionalPauseDialogObjectMap.remove( portH );
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpTE79bF.p.
% Please follow local copyright laws when handling this file.

