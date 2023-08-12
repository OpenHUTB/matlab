function hNetworkComp = instantiateNetwork( hN, hnewNet, hInSignals, hOutSignals,  ...
instanceName )






narginchk( 5, 5 );
hNetworkComp = hN.addComponent( 'ntwk_instance_comp', hnewNet );
pirelab.connectNtwkInstComp( hNetworkComp, hInSignals, hOutSignals );
hNetworkComp.Name = instanceName;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpYyhqNE.p.
% Please follow local copyright laws when handling this file.

