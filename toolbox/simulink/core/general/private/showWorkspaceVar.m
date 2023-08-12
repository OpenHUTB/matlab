function showWorkspaceVar( location, var_name, filename )




dlgSrc = '';
context = '';
switch ( location )
case 'base'
dlgSrc = wsDDGSource( var_name, '' );
case 'dictionary'
dd = Simulink.dd.open( filename );
showResolved = true;
if ischar( var_name )
entry_spec = [ 'Design_Data.', var_name ];
else 
assert( isnumeric( var_name ) );
entry_spec = var_name;
var_name = dd.getEntryInfo( var_name ).Name;
end 
dlgSrc = Simulink.dd.EntryDDGSource( dd, entry_spec, showResolved );
dictionaryObj = Simulink.data.dictionary.open( filename );
context = getSection( dictionaryObj, 'Design Data' );
close( dictionaryObj );
case 'model'
dlgSrc = wsDDGSource( var_name, filename );
context = get_param( filename, 'ModelWorkspace' );
case 'mask'
open_system( filename, 'mask' );
case 'model mask'
mdlHandle = get_param( filename, 'Handle' );
if ~isempty( mdlHandle )
SLM3I.SLDomain.openModelMaskDialogParams( mdlHandle );
end 
end 
if ~isempty( dlgSrc )

DAStudio.Dialog( dlgSrc, var_name, 'DLG_STANDALONE', context );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcALUAb.p.
% Please follow local copyright laws when handling this file.

