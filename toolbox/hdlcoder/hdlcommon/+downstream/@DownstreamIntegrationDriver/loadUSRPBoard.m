function loadUSRPBoard( obj, boardName )



setToolForBoard( obj, boardName );

ubinfo = USRPFPGATarget.USRPBuildInfo;
ubinfo.Board = boardName;
[ FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed ] = ubinfo.getFPGAParts;
try 
obj.set( 'Family', FPGAFamily );
obj.set( 'Device', FPGADevice );
obj.set( 'Package', FPGAPackage );
obj.set( 'Speed', FPGASpeed );
catch ME
errMsg = sprintf( [ 'The FPGA device used in %s\n', 'is %s/%s/%s/%s.\n', 'This FPGA device is not supported by current synthesis tool\n', '%s %s.\n' ], boardName, FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed, obj.get( 'Tool' ), obj.getToolVersion );
setupToolMsg = obj.printSetupToolMsg;
error( message( 'hdlcommon:workflow:UnsupportedDevice', errMsg, setupToolMsg ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpabSHLS.p.
% Please follow local copyright laws when handling this file.

