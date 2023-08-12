function programXilinxFPGA( bitstreamfile, chainposition )

assert( exist( bitstreamfile, 'file' ) == 2, message( 'soc:msgs:BitstreamNotFound', bitstreamfile ) );


disp( [ '### ', message( 'soc:msgs:CheckingProgrammingTool' ).getString ] );
vivadoToolExe = soc.util.getVivadoPath(  );
[ retval, ~ ] = system( [ vivadoToolExe, ' -version' ] );
assert( retval == 0, message( 'soc:msgs:VivadoNotFound' ) );


batchFile = l_generateBatchFile( bitstreamfile, chainposition );


disp( [ '### ', message( 'soc:msgs:LoadingInProgress', bitstreamfile ).getString ] );

[ retval, msg ] = system( [ vivadoToolExe, ' -mode batch -source ', batchFile ] );

assert( retval == 0, message( 'soc:msgs:LoadingFailed', msg ) );

disp( [ '### ', message( 'soc:msgs:LoadingPassed', bitstreamfile ).getString ] );

end 

function batchFile = l_generateBatchFile( bitstreamfile, chainposition )

cmds = [ 'set chain_position ', num2str( chainposition - 1 ), newline ...
, 'open_hw', newline ...
, 'connect_hw_server -url localhost:3121', newline ...
, 'open_hw_target', newline ...
, 'current_hw_device [lindex [get_hw_devices] $chain_position]', newline ...
, 'refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] $chain_position]', newline ...
, 'set_property PROGRAM.FILE {', bitstreamfile, '} [lindex [get_hw_devices] $chain_position]', newline ...
, 'program_hw_devices [lindex [get_hw_devices] $chain_position]', newline ...
, 'disconnect_hw_server' ];


batchFile = '_vivado_program.cmd';
fid = fopen( batchFile, 'w' );

if fid ==  - 1
onCleanupObj = [  ];
else 
onCleanupObj = onCleanup( @(  )fclose( fid ) );
end 

assert( fid ~=  - 1, message( 'soc:msgs:BatchFileCreationFailed', batchFile ) );


fwrite( fid, cmds );


delete( onCleanupObj );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp9EByDx.p.
% Please follow local copyright laws when handling this file.

