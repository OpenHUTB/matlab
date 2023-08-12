function [ leftCursor, rightCursor ] = findFailureRegionForVerifySignal( verifySigId, dir, currentLeftCursor, currentRightCursor )




R36
verifySigId( 1, 1 ){ mustBeNumeric, mustBeReal }
dir( 1, : )char{ mustBeMember( dir, { 'prev', 'next' } ) }
currentLeftCursor( 1, 1 ){ mustBeNumeric, mustBeReal }
currentRightCursor( 1, 1 ){ mustBeNumeric, mustBeReal }
end 

failureSigID = stm.internal.verify.createFailureRegionSignal( verifySigId );

switch dir
case 'prev'
cursorVal = currentLeftCursor;
case 'next'
cursorVal = currentRightCursor;
end 
eng = Simulink.sdi.Instance.engine(  );

leftCursor = Simulink.sdi.getFailureRegion( eng.sigRepository, failureSigID, cursorVal, 'L', dir );
rightCursor = Simulink.sdi.getFailureRegion( eng.sigRepository, failureSigID, cursorVal, 'R', dir );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjBsQdj.p.
% Please follow local copyright laws when handling this file.

