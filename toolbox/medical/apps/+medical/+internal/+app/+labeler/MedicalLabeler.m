classdef MedicalLabeler < handle




properties ( SetAccess = private, GetAccess = ?uitest.factory.Tester )

View medical.internal.app.labeler.View

end 

properties ( Access = private )

Model medical.internal.app.labeler.Model
Controller medical.internal.app.labeler.Controller

end 

methods 

function self = MedicalLabeler( input, opts )

R36
input = [  ]
opts.UseDarkMode( 1, 1 )matlab.lang.OnOffSwitchState = false;
end 


if ~isempty( input )
input = validateInput( input );
end 

self.Model = medical.internal.app.labeler.Model(  );
self.View = medical.internal.app.labeler.View( opts.UseDarkMode );

if ~isvalid( self.View )
return ;
end 

self.Controller = medical.internal.app.labeler.Controller( self.Model, self.View );

self.View.setBusy( false );


if ~isempty( input )

if isstring( input )

if strcmp( input, "Volume" )
self.View.newVolumeSessionRequested(  );

elseif strcmp( input, "Image" )
self.View.newImageSessionRequested(  );

elseif isfolder( input )
self.View.openSessionFromDirectory( input );
end 

elseif isa( input, 'groundTruthMedical' )

if isa( input.DataSource, 'medical.labeler.loading.VolumeSource' )
self.View.newVolumeSessionRequested(  );

elseif isa( input.DataSource, 'medical.labeler.loading.ImageSource' )
self.View.newImageSessionRequested(  );

end 

self.View.importGroundTruthFromWksp( input );

end 

end 


self.View.requestToRefreshRecentSessions(  );
self.View.requestToRefreshUserDefinedVolumeRenderings(  );

self.View.canTheAppClose( true );

end 

end 

end 


function input = validateInput( input )

input = convertCharsToStrings( input );

if isstring( input )

if isfile( input )
input = medical.internal.app.labeler.utils.readGTruthMedicalFromMATFile( filename );
elseif isfolder( input )

else 
input = validatestring( input, [ "Volume", "Image" ] );
end 

elseif isa( input, 'groundTruthMedical' )

else 
error( message( 'medical:medicalLabeler:invalidInput' ) );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNUrxGn.p.
% Please follow local copyright laws when handling this file.

