function saveParallelConfigurationFile( modelHStr )
daRoot = DAStudio.Root;
mgr = {  };
explorers = daRoot.find( '-isa', 'Simulink.ParallelExecutionExplorer' );
for i = 1:length( explorers )
if strcmp( explorers( i ).getRoot.ModelHandleString, modelHStr )
mgr = explorers( i ).getRoot;
break ;
end 
end 
children = mgr.executionNodes;
execModes( length( children ) ) =  - 1;
for i = 1:length( children )
strExecMode = children( i ).ExecutionMode;
switch ( strExecMode )
case 'Auto'
execModes( i ) =  - 1;
case 'Off'
execModes( i ) = 0;
case 'On'
execModes( i ) = 1;
end 
end 
buildDir = getBuildDir( get_param( mgr.model, 'Name' ) );
nodeExecutionModesFilename =  ...
fullfile( buildDir, 'parallelExecutionNodeExecutionModes.txt' );
fid = fopen( nodeExecutionModesFilename, 'w' );
fprintf( fid, '%d\n', execModes );
fclose( fid );
end 

function buildDir = getBuildDir( model )

fileGenCfg = Simulink.fileGenControl( 'getConfig' );
buildDir = fullfile( fileGenCfg.CodeGenFolder, 'slprj', 'raccel', model );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSGopd8.p.
% Please follow local copyright laws when handling this file.

