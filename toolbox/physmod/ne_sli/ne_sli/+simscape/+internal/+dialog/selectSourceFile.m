function [ resolvedName, theSelection ] = selectSourceFile( current )







R36
current( 1, 1 )string = string( missing )
end 


resolvedName = string( missing );
theSelection = string( missing );


if nargin < 1 || ismissing( current )
current = "";
end 

currentPath = which( current );
currentPathDir = fileparts( currentPath );
if ~isempty( currentPath ) && exist( currentPathDir, 'dir' )
currentPath = currentPathDir;
elseif exist( current, 'dir' )
currentPath = current;
elseif exist( current, 'file' )
currentDir = fileparts( current );
currentPath = currentDir;
else 
currentPath = '';
end 


browseTitle = getString( message( 'physmod:ne_sli:dialog:BrowseSourceDialogTitle' ) );
[ theFile, selectedPath ] = uigetfile( { '*.ssc;*.sscp;' }, browseTitle, currentPath );


if ischar( theFile )

theSelection = string( fullfile( selectedPath, theFile ) );
nesl_getfunctioninfo = nesl_private( 'nesl_getfunctioninfo' );
info = nesl_getfunctioninfo( theSelection );


nesl_promptifaddpathneeded = nesl_private( 'nesl_promptifaddpathneeded' );
info = nesl_promptifaddpathneeded( info );


nesl_resolvefunctioninfo = nesl_private( 'nesl_resolvefunctioninfo' );
[ result, msg ] = nesl_resolvefunctioninfo( info );
if ~isempty( result )
resolvedName = string( result );
else 
errordlg( msg, getString( message( 'physmod:ne_sli:dialog:ErrorWhileLoadingComponent' ) ), 'modal' );
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpn4Vb0z.p.
% Please follow local copyright laws when handling this file.

