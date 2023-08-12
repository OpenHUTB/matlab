function sigSpecComp = insertSignalSpecOnSignal( hN, hInSig )





sigSpec = hN.addSignal( hInSig );

sigSpec.acquireReceivers( hInSig );

sigSpecComp = pirelab.getWireComp( hN, hInSig, sigSpec, 'sigspec' );
sigSpecComp.setSourceBlock( 'sigspec' );
% Decoded using De-pcode utility v1.2 from file /tmp/tmpjImPcu.p.
% Please follow local copyright laws when handling this file.

