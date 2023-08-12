function restore_backup( backup_file )


try 
i_restore( backup_file )
catch E
errordlg( E.message, DAStudio.message( 'Simulink:util:RestoreBackupError' ) );
end 
end 

function i_restore( backup_file )

[ d, n, e ] = slfileparts( backup_file );
[ ~, modelname, f ] = slfileparts( n );
assert( strcmp( f, '.slx' ) || strcmp( f, '.mdl' ),  ...
'Supplied file must be a backup of an SLX or MDL file' );
restored_file = slfullfile( d, n );
count = 1;
modelname_orig = modelname;
while ~isempty( Simulink.loadsave.resolveFile( restored_file ) ) ||  ...
bdIsLoaded( modelname )


modelname = sprintf( '%s%d', modelname_orig, count );
restored_file = slfullfile( d, [ modelname, f ] );
count = count + 1;
assert( count < 50, 'Failed to find an unused file name' );
end 

ok = DAStudio.message( 'Simulink:editor:DialogOK' );
cancel = DAStudio.message( 'Simulink:editor:DialogCancel' );
out = questdlg(  ...
DAStudio.message( 'Simulink:util:RestoreBackupPrompt', [ n, e ], [ modelname, f ] ),  ...
DAStudio.message( 'Simulink:util:RestoreBackup' ),  ...
ok, cancel, cancel );
if strcmp( out, ok )
copyfile( backup_file, restored_file );
open_system( restored_file );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQYI3ht.p.
% Please follow local copyright laws when handling this file.

