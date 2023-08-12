function loadTool( obj, toolName )





backToolDriver = obj.hToolDriver;




[ FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed ] = obj.getFPGAParts(  );

try 

obj.hToolDriver = downstream.ToolDriver( obj );

obj.hToolDriver.loadTool( toolName );

fullProjectDir = fullfile( obj.getProjectFolder, obj.getProjectPath );
obj.setProjectPath( fullProjectDir );
catch ME

obj.hToolDriver = backToolDriver;

rethrow( ME );
end 

if ~isempty( FPGAFamily ) || ~isempty( FPGADevice ) || ~isempty( FPGAPackage ) || ~isempty( FPGASpeed )





if obj.isGenericWorkflow || obj.isBoardEmpty




familyNameList = obj.getOptionChoice( 'Family' );
isIn = ~isempty( intersect( FPGAFamily, familyNameList ) );
if isIn
setFPGAParts( obj, FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed, '' );
end 
else 









boardName = obj.get( 'Board' );
boardNameList = obj.getOptionChoice( 'Board' );
isIn = ~isempty( intersect( boardName, boardNameList ) );


isBoardStatic = obj.isBoardLoaded && strcmpi( boardName, obj.hTurnkey.hBoard.BoardName ) ||  ...
obj.isFILBoardLoaded && strcmpi( boardName, obj.hFilBuildInfo.Board );
if isIn && isBoardStatic
if ~obj.isGenericIPPlatform
setFPGAParts( obj, FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed, boardName );
else 



familyNameList = obj.getOptionChoice( 'Family' );
isIn = ~isempty( intersect( FPGAFamily, familyNameList ) );
if isIn
setFPGAParts( obj, FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed, '' );
end 
end 




if obj.isIPCoreGen
obj.hIP.initIPPlatform;
end 
end 

end 




end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYHMGad.p.
% Please follow local copyright laws when handling this file.

