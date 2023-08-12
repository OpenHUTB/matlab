


classdef SRDialogHelper



methods ( Static )
function BrowseButtonCallback( varargin )
try 
dialogH = varargin{ 1 };
widgetTag = varargin{ 2 };
browser = SubsystemReferenceBrowser( true, [  ], dialogH, '', '' );
subSystemNameBeforeBrowse = dialogH.getWidgetValue( widgetTag );









browser.browse( dialogH, widgetTag, false );


subSystemNameAfterBrowse = dialogH.getWidgetValue( widgetTag );
isSlimDialog = strcmp( dialogH.dialogMode, 'Slim' );
if ( isSlimDialog && ~strcmp( subSystemNameBeforeBrowse, subSystemNameAfterBrowse ) )
set_param( dialogH.getDialogSource.getBlock.Handle,  ...
'ReferencedSubsystem', subSystemNameAfterBrowse );
end 
catch E
throwAsCaller( E )
end 
end 

function OpenSRButtonCallback( varargin )
blockHandle = varargin{ 1 };
referencedSubsystem = get_param( blockHandle, 'ReferencedSubsystem' );
open_system( referencedSubsystem );
end 

function ConvertToSRButtonCallback( varargin )
try 
blockHandle = varargin{ 1 };
subsystemDlgHandle = varargin{ 2 };
dlgHandle = SSRefConversionDialog.createDialog( blockHandle, subsystemDlgHandle );
dlgHandle.show(  );
catch E
throwAsCaller( E )
end 
end 


function [ isLoaded, loadedModelPath ] = findLoadedFile( fileName )

[ ~, modelNameWithoutExt, ~ ] = fileparts( fileName );
loadedModelPath = [  ];

loadedModel = find_system( 'Type', 'block_diagram', 'Name', modelNameWithoutExt );
isLoaded = ~isempty( loadedModel );
if isLoaded

loadedModelPath = get_param( loadedModel{ 1 }, 'FileName' );
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYAFfU_.p.
% Please follow local copyright laws when handling this file.

