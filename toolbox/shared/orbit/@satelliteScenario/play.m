function play( scenario, nameValueArgs )
















































































R36
scenario( 1, 1 )satelliteScenario
nameValueArgs.PlaybackSpeedMultiplier( 1, 1 )double{ mustBeFinite, mustBeReal, mustBeNonsparse }
nameValueArgs.Viewer matlabshared.satellitescenario.Viewer = scenario.Viewers
end 


if ~isvalid( scenario )
msg = message(  ...
'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',  ...
'SCENARIO' );
error( msg );
end 

viewer = nameValueArgs.Viewer;
usingDefaultSpeed = ~isfield( nameValueArgs, "PlaybackSpeedMultiplier" );

numViewers = numel( viewer );
matlabshared.satellitescenario.ScenarioGraphic.validateViewerScenario( viewer, scenario );

for idx = 1:numViewers

addWaitBar( viewer( idx ), 'simulating' );
end 

try 


simulate( scenario.Simulator );


if isempty( viewer ) || ( numViewers == 1 && ~isvalid( viewer.GlobeViewer ) )
viewer = satelliteScenarioViewer( scenario, "Empty", true );
numViewers = 1;
addWaitBar( viewer, 'plotting' );
end 




if ( scenario.StartTime == scenario.StopTime ) ||  ...
( numel( scenario.Simulator.TimeHistory ) <= 1 )
show( scenario );
for idx = 1:numViewers

removeWaitBar( viewer( idx ) );
end 
return 
end 


for idx = 1:numViewers
currentViewer = viewer( idx );
addWaitBar( currentViewer, 'plotting' );

writeCZML( currentViewer );
end 




waitForResponse = false;
for idx = 1:numViewers
currentViewer = viewer( idx );
if ( idx == numViewers )

waitForResponse = true;
end 


clear( currentViewer, false );



if usingDefaultSpeed
speedStruct = currentViewer.GlobeViewer.getPlaybackSpeed(  );
playbackSpeed = speedStruct.Speed;
else 
playbackSpeed = nameValueArgs.PlaybackSpeedMultiplier;
end 

playback( currentViewer, waitForResponse );
end 




for idx = 1:numViewers


currentViewer = viewer( idx );
currentViewer.PlaybackSpeedMultiplier = playbackSpeed;
removeWaitBar( currentViewer );
figure( currentViewer.UIFigure );
end 
catch ME

for idx = 1:numViewers
removeWaitBar( viewer( idx ) );
end 
rethrow( ME );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpGoBX0J.p.
% Please follow local copyright laws when handling this file.

