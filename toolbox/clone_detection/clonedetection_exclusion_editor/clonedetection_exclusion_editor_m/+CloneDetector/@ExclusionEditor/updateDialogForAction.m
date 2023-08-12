



function updateDialogForAction( this, actionName, actionData )
R36
this
actionName
actionData = ''
end 

exclusionWindow = Advisor.UIService.getInstance.getWindowById( this.AppID, this.windowId );
windowTitle = DAStudio.message( 'sl_pir_cpp:creator:cloneDetectionExclusionEditor' );
dirtyStatus = false;

switch ( actionName )
case this.UpdateDialogAction.Save

savedInText = DAStudio.message( 'slcheck:filtercatalog:Editor_SavedIn' );
windowTitle = [ windowTitle, ' - ', savedInText, ' ', actionData ];
case this.UpdateDialogAction.Dirty

windowTitle = strcat( windowTitle, '*' );
dirtyStatus = true;
end 

if exclusionWindow.isOpen(  )
exclusionWindow.setTitle( windowTitle );
exclusionWindow.publishToUI( 'ExclusionEditorClones::setDirty', dirtyStatus );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpYIGQ2Q.p.
% Please follow local copyright laws when handling this file.

