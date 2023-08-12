function [ location, fullName, fileName, isExplorable, enabled ] = parseLocation( mdl_name, location, varName )




isExplorable = true;
enabled = true;
switch ( location )
case ''
location = '';
enabled = true;
fileName = mdl_name;
fullName = mdl_name;
case 'Global'
dataAccessor = Simulink.data.DataAccessor.createForExternalData( mdl_name );
varId = dataAccessor.identifyByName( varName );
assert( numel( varId ) == 1 );
src = varId.getDataSourceFriendlyName(  );

if ( strcmp( src, 'base workspace' ) )
location = 'base';
fullName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Base' );
fileName = '';
else 
assert( contains( src, '.sldd' ) );
location = 'dictionary';
fullName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Dictionary' );
fileName = dataAccessor.getConnectedSource( varId );
end 
case 'DictionaryDuplicate'
location = 'dictionary';
fullName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_DD_Duplicates' );
ddName = get_param( mdl_name, 'DataDictionary' );
fileName = ddName;
enabled = false;
isExplorable = false;
case 'Model'
location = 'model';
fullName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Model' );
fileName = mdl_name;
case 'Class'
location = 'class';
fullName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Classdef' );
fileName = mdl_name;
enabled = false;
isExplorable = false;
case 'DictionaryAndBaseWS'


location = 'dictionary';
fullName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_DD_Duplicates' );
ddName = get_param( mdl_name, 'DataDictionary' );
fileName = ddName;
enabled = false;
isExplorable = false;
case 'UnknownLocation'
location = 'unknown';
fullName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Undetermined' );
fileName = mdl_name;
enabled = false;
isExplorable = false;
otherwise 
try 
isExplorable = false;
if ( endsWith( location, 'Model Mask' ) )
maskName = get_param( mdl_name, 'Name' );
fileName = strrep( mdl_name, sprintf( '\n' ), ' ' );
maskDlgItems = get_param( mdl_name, 'MaskNames' );
location = 'model mask';
isExplorable = false;
enabled = true;

fullName = [ DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Mask' ), ': ', maskName ];
else 
maskName = get_param( location, 'Name' );
fileName = strrep( location, sprintf( '\n' ), ' ' );
maskDlgItems = get_param( location, 'MaskNames' );
location = 'mask';
if ismember( varName, maskDlgItems )
fullName = [ DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Mask' ), ': ', maskName ];
enabled = true;
isExplorable = true;
else 
fullName = [ DAStudio.message( 'Simulink:dialog:WorkspaceLocation_MaskInit' ), ': ', maskName ];
enabled = false;
end 
end 

catch E
location = 'unknown';
fullName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Undetermined' );
fileName = mdl_name;
enabled = false;
isExplorable = false;
end 
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpMWI9ov.p.
% Please follow local copyright laws when handling this file.

