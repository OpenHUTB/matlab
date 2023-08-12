function setTargetLibPathOnSlProcess( p )


R36
p( 1, 1 )slprocess.Process
end 
archstr = computer( 'arch' );
if ismac
p.setenv( 'DYLD_LIBRARY_PATH', [ matlabroot, '/bin/', archstr ] );
elseif isunix
p.setenv( 'LD_LIBRARY_PATH', [ matlabroot, '/bin/', archstr ] );
elseif ispc
p.setenv( 'PATH', [ matlabroot, '\bin\', archstr ] );
else 
error( 'Platform not supported' );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpepRiA_.p.
% Please follow local copyright laws when handling this file.

