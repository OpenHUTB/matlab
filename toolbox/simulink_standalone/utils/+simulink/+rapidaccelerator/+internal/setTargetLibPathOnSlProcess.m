function setTargetLibPathOnSlProcess( p )

arguments
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


