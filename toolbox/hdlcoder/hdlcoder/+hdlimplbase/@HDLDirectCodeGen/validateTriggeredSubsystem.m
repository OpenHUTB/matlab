function v = validateTriggeredSubsystem( this, hN )



v = hdlvalidatestruct;

if hN.hasTriggeredInstances(  )
v = hdlvalidatestruct( 1, message( 'hdlcoder:validate:illegalBlockInTriggeredSubsys' ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYt1UZF.p.
% Please follow local copyright laws when handling this file.

