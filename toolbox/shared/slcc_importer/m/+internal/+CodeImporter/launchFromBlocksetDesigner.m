function launchFromBlocksetDesigner( projRootPath, libName, parentId )

arguments
    projRootPath( 1, 1 )string
    libName( 1, 1 )string
    parentId( 1, 1 )string
end

obj = Simulink.CodeImporter( libName );
outputFolder = fullfile( projRootPath, libName );
if ~exist( outputFolder, 'dir' )
    mkdir( outputFolder );
end
addpath( outputFolder );
obj.OutputFolder = outputFolder;
obj.launchedFromBlocksetDesigner = true;
obj.ParentIdForBlocksetDesigner = parentId;
obj.view;
end
