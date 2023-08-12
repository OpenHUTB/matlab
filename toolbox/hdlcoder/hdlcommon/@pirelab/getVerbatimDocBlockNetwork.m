function hNewC = getVerbatimDocBlockNetwork( hN, hC, base_text )


BlackBoxNetworkName = hC.Name;
try 
EntityName = hdlget_param( getfullname( hC.SimulinkHandle ), 'EntityName' );
if ~isempty( EntityName )
BlackBoxNetworkName = EntityName;
end 
catch mEx %#ok<NASGU>
end 

inport = struct( 'Names', {  }, 'Rates', [  ], 'Types', [  ] );
outport = struct( 'Names', {  }, 'Types', [  ] );

Lin = length( hC.PirInputPorts );

for itr = 1:Lin
inport( 1 ).Names{ itr } = hC.PirInputPorts( itr ).Name;
inport( 1 ).Rates( itr ) = hC.PirInputSignals( itr ).SimulinkRate;
inport( 1 ).Types( itr ) = hC.PirInputSignals( itr ).Type;
end 

Lout = length( hC.PirOutputPorts );
for itr = 1:Lout
outport( 1 ).Names{ itr } = hC.PirOutputPorts( itr ).Name;
outport( 1 ).Rates( itr ) = hC.PirOutputSignals( itr ).SimulinkRate;
outport( 1 ).Types( itr ) = hC.PirOutputSignals( itr ).Type;
end 



verbatimNet = pirelab.createNewNetworkWithInterface( 'RefComponent', hC, 'Network', hN, 'Name', BlackBoxNetworkName );
verbatimNet.setNetworkKind( 'Verbatim' );



verbatimNet.dontTouch( true );
hNewC = pircore.getVerbatimTextComp( verbatimNet, hC, base_text );
hC.setPreserve( false );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpI_nGal.p.
% Please follow local copyright laws when handling this file.

