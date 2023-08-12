function out = openautosave( autosavefile )









if nargout, out = [  ];end 


[ d, n ] = fileparts( autosavefile );
[ ~, modelname, e ] = fileparts( n );
if ~strcmp( e, '.slx' ) && ~strcmp( e, '.mdl' )

edit( autosavefile );
return ;
end 

modelfile = fullfile( d, n );
if exist( modelfile, 'file' )
df = dir( modelfile );
af = dir( autosavefile );
if df.datenum < af.datenum


i_openmodel( modelfile, modelname );
else 


i_openautosave( autosavefile, modelname, true );
end 
else 

i_openautosave( autosavefile, modelname, false );
end 
end 

function i_openmodel( modelfile, modelname )


msg = DAStudio.message( 'Simulink:dialog:autosaveOpenNewer', modelname, modelname );
if i_dialog( msg )
open( modelfile );
end 
end 

function i_openautosave( autosavefile, modelname, model_file_exists )

restorename = [ modelname, '_restored_from_autosave' ];
if model_file_exists
msg = DAStudio.message( 'Simulink:dialog:autosaveOpenOlder', modelname, restorename );
else 
msg = DAStudio.message( 'Simulink:dialog:autosaveOpenMissing', modelname, restorename );
end 
if i_dialog( msg )
Simulink.internal.newSystemFromFile( restorename, autosavefile, ExecuteCallbacks = false );
open_system( restorename );
end 

end 

function accepted = i_dialog( msg )


title = DAStudio.message( 'Simulink:dialog:autosaveOpenTitle' );
yes = DAStudio.message( 'Simulink:editor:DialogYes' );
no = DAStudio.message( 'Simulink:editor:DialogNo' );
cancel = DAStudio.message( 'Simulink:editor:DialogCancel' );
answer = questdlg( msg, title, yes, no, cancel, yes );
accepted = strcmp( answer, yes );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp_qPKF8.p.
% Please follow local copyright laws when handling this file.

