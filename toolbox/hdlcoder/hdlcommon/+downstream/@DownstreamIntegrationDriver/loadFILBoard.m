function loadFILBoard( obj, boardName )




setToolForBoard( obj, boardName );


obj.hFilBuildInfo.Board = boardName;

try 
obj.set( 'Family', obj.hFilBuildInfo.BoardObj.Component.PartInfo.FPGAFamily );
obj.set( 'Device', obj.hFilBuildInfo.BoardObj.Component.PartInfo.FPGADevice );
obj.set( 'Package', obj.hFilBuildInfo.BoardObj.Component.PartInfo.FPGAPackage );
obj.set( 'Speed', obj.hFilBuildInfo.BoardObj.Component.PartInfo.FPGASpeed );
catch ME
errMsg = sprintf( [ 'The FPGA device used in %s\n', 'is %s/%s/%s/%s.\n', 'This FPGA device is not supported by current synthesis tool\n', '%s %s.\n' ], boardName, obj.hFilBuildInfo.BoardObj.Component.PartInfo.FPGAFamily, obj.hFilBuildInfo.BoardObj.Component.PartInfo.FPGADevice, obj.hFilBuildInfo.BoardObj.Component.PartInfo.FPGAPackage, obj.hFilBuildInfo.BoardObj.Component.PartInfo.FPGASpeed, obj.get( 'Tool' ), obj.getToolVersion );
setupToolMsg = obj.printSetupToolMsg;
error( message( 'hdlcommon:workflow:UnsupportedDevice', errMsg, setupToolMsg ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcoaihl.p.
% Please follow local copyright laws when handling this file.

