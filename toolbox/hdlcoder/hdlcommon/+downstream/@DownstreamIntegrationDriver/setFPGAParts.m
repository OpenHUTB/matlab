function setFPGAParts( obj, FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed, boardName )





try 

obj.set( 'Family', FPGAFamily );
obj.set( 'Device', FPGADevice );
obj.set( 'Package', FPGAPackage );
obj.set( 'Speed', FPGASpeed );
catch ME %#ok<NASGU>

obj.reportUnsupportedDevice( FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed, boardName );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdrKaTw.p.
% Please follow local copyright laws when handling this file.

