function viewer = satelliteScenarioViewer( scenario, nameValueArgs )


































































R36
scenario
nameValueArgs.Empty = false
nameValueArgs.Name{ mustBeTextScalar }
nameValueArgs.Position( 1, 4 )double{ mustBeReal, mustBeFinite, mustBeNonsparse }
nameValueArgs.Basemap{ mustBeValidBasemap( nameValueArgs.Basemap ) }
nameValueArgs.PlaybackSpeedMultiplier( 1, 1 )double{ mustBeFinite, mustBeReal, mustBeNonsparse }
nameValueArgs.CameraReferenceFrame{ mustBeMember( nameValueArgs.CameraReferenceFrame, { 'ECEF', 'Inertial' } ) }
nameValueArgs.CurrentTime( 1, 1 )datetime
nameValueArgs.Dimension{ mustBeMember( nameValueArgs.Dimension, { '3D', '2D' } ) }
nameValueArgs.ShowDetails( 1, 1 )logical = true
end 

launchEmpty = nameValueArgs.Empty;
nameValueArgs = rmfield( nameValueArgs, 'Empty' );

args = [ fieldnames( nameValueArgs ), struct2cell( nameValueArgs ) ];
args = args';
args = args( : );
viewer = matlabshared.satellitescenario.Viewer( scenario, args{ : } );
scenario.CurrentViewer = viewer;
scenario.Viewers( end  + 1 ) = viewer;
if ( ~launchEmpty )
show( scenario, "Viewer", viewer );
else 



for graphic = scenario.ScenarioGraphics
if ( isa( graphic{ : }, 'matlabshared.satellitescenario.GroundTrack' ) && strcmp( graphic{ : }.VisibilityMode, 'auto' ) )
viewer.setGraphicVisibility( graphic{ : }.getGraphicID, false );
end 
end 
end 
end 



function mustBeValidBasemap( basemap )

mustBeMember( basemap, globe.internal.GlobeModel.basemapchoices( false ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpCfCoUa.p.
% Please follow local copyright laws when handling this file.

