function [ markerH1, markerH2, markerV1, markerV2 ] = get2DOrientationMarkers( sliceDirection, displayConvention )




R36

sliceDirection
displayConvention( 1, 1 )string{ mustBeMember( displayConvention, [ "Radiological", "Neurological" ] ) } = "Radiological"

end 

switch sliceDirection

case { medical.internal.app.labeler.enums.SliceDirection.Transverse,  ...
"transverse", "xy" }
markerH1 = getString( message( 'medical:medicalLabeler:R' ) );
markerH2 = getString( message( 'medical:medicalLabeler:L' ) );
markerV1 = getString( message( 'medical:medicalLabeler:A' ) );
markerV2 = getString( message( 'medical:medicalLabeler:P' ) );
if displayConvention == "Neurological"

[ markerH1, markerH2 ] = deal( markerH2, markerH1 );
end 

case { medical.internal.app.labeler.enums.SliceDirection.Coronal,  ...
"coronal", "yz" }
markerH1 = getString( message( 'medical:medicalLabeler:R' ) );
markerH2 = getString( message( 'medical:medicalLabeler:L' ) );
markerV1 = getString( message( 'medical:medicalLabeler:S' ) );
markerV2 = getString( message( 'medical:medicalLabeler:I' ) );
if displayConvention == "Neurological"

[ markerH1, markerH2 ] = deal( markerH2, markerH1 );
end 

case { medical.internal.app.labeler.enums.SliceDirection.Sagittal,  ...
"sagittal", "xz" }
markerH1 = getString( message( 'medical:medicalLabeler:A' ) );
markerH2 = getString( message( 'medical:medicalLabeler:P' ) );
markerV1 = getString( message( 'medical:medicalLabeler:S' ) );
markerV2 = getString( message( 'medical:medicalLabeler:I' ) );

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpk_yF0L.p.
% Please follow local copyright laws when handling this file.

