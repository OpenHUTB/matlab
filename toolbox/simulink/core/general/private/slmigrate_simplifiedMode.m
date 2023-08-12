function result = slmigrate_simplifiedMode( system, ~ )




systemName = get_param( system, 'Name' );

result = [  ];


disp( [ '### ' ...
, DAStudio.message( 'Simulink:tools:SimplifiedModeMigrateRunning', systemName ) ] );

set_param( system, 'UnderspecifiedInitializationDetection', 'Simplified' );
set_param( system, 'MergeDetectMultiDrivingBlocksExec', 'Error' );

result = DAStudio.message( 'Simulink:tools:SimplifiedModeMigrateCompleted' );



end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpNZ4ITA.p.
% Please follow local copyright laws when handling this file.

