function updateBrowserWindowTitle( modelHandle, isDirty, fullFileName )




R36
modelHandle( 1, 1 )double
isDirty( 1, 1 )logical
fullFileName( 1, 1 )string
end 

if isDirty
dirtyTag = "*";
else 
dirtyTag = "";
end 

commonWindowTitle = string( message( "multisim:SetupGUI:WindowTitle" ).getString(  ) );
if fullFileName ~= ""
[ ~, fileTitle, ~ ] = fileparts( fullFileName );
windowTitle = commonWindowTitle + dirtyTag + " - " + fileTitle;
else 
windowTitle = commonWindowTitle + dirtyTag;
end 

dataId = simulink.multisim.internal.blockDiagramAssociatedDataId(  );
modelName = get_param( modelHandle, "Name" );
studios = simulink.multisim.internal.getAllStudiosForModel( modelName );

for studioIdx = 1:numel( studios )
dockedComponent = studios( studioIdx ).getComponent( "GLUE2:DDG Component", dataId );
if ~isempty( dockedComponent )
studios( studioIdx ).setDockComponentTitle( dockedComponent, windowTitle );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpzW8Vk8.p.
% Please follow local copyright laws when handling this file.

