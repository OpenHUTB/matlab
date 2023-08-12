function sampleTimes = slGetSampleTimes( obj )



Simulink.SampleTime.empty( 0, 0 );
needToTerm = false;
mdl = '';

try 
mdl = get_param( bdroot( obj ), 'Name' );
bdType = get_param( mdl, 'BlockDiagramType' );



if ( ~strcmp( bdType, 'model' ) )
localCleanup( mdl, needToTerm );
DAStudio.error( 'Simulink:utility:SlGetSampleTimesNotModel', mdl, bdType );
end 

simStatus = get_param( mdl, 'SimulationStatus' );

if strcmpi( simStatus, 'updating' )
DAStudio.error( 'Simulink:utility:cannotGetSampleTimesWhileUpdating' );
end 

if ~strcmpi( simStatus, 'paused' ) && ~strcmpi( simStatus, 'initializing' )
feval( mdl, 'init' );
needToTerm = true;
end 

if ( strcmp( get_param( obj, 'Type' ), 'block' ) )
sampleTimesArr = get_param( obj, 'LastKnownCompiledSampleTimes' );
elseif ( strcmp( get_param( obj, 'Type' ), 'block_diagram' ) )
sampleTimesArr = get_param( obj, 'SampleTimes' );
else 
DAStudio.error( 'Simulink:utility:SlGetSampleTimesBadInput1' );
end 

for idx = 1:length( sampleTimesArr )
sampleTimes( idx ) = Simulink.SampleTime( sampleTimesArr( idx ) );%#ok
end 
catch e
localCleanup( mdl, needToTerm );
rethrow( e )
end 

localCleanup( mdl, needToTerm );

end 


function localCleanup( mdl, needToTerm )

if ( needToTerm )
feval( mdl, 'term' );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpau7Yct.p.
% Please follow local copyright laws when handling this file.

