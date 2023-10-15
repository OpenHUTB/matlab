function updateBrowserWindowTitle( modelHandle, isDirty, fullFileName )

arguments
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

