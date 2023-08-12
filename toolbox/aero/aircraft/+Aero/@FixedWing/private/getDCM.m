function DCM = getDCM( state, frame )




R36
state( 1, 1 )Aero.FixedWing.State
frame( 1, 1 )Aero.Aircraft.internal.datatype.ReferenceFrame
end 

switch frame
case Aero.Aircraft.internal.datatype.ReferenceFrame.Body
DCM = eye( 3 );
case Aero.Aircraft.internal.datatype.ReferenceFrame.Wind
DCM = state.BodyToWindMatrix;
case Aero.Aircraft.internal.datatype.ReferenceFrame.Stability
DCM = state.BodyToStabilityMatrix;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpnIdPoL.p.
% Please follow local copyright laws when handling this file.

