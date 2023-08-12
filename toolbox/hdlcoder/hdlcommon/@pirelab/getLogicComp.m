function logicComp = getLogicComp( hN, hSignalsIn, hSignalsOut, op, compName, desc, slHandle )




validLogicOps = { 'and', 'or', 'nand', 'nor', 'xor', 'not', 'xnor', 'nxor' };
if ~any( strcmpi( validLogicOps, op ) )
error( message( 'hdlcommon:hdlcommon:BadLogicOp', op ) );
end 

if nargin < 7
slHandle =  - 1;
end 

if nargin < 6
desc = '';
end 

if nargin < 5
compName = op;
end 

if hSignalsOut.Type.is1BitType
opSignal = hSignalsOut;
logicComp = pircore.getLogicComp( hN, hSignalsIn, opSignal, op, compName, desc, slHandle );
else 




[ dims, ~ ] = pirelab.getVectorTypeInfo( hSignalsOut );
hBlockOutType = pirelab.getPirVectorType( pir_boolean_t, dims );
opSignal = hN.addSignal( hBlockOutType, [ compName, '_bool' ] );
opSignal.SimulinkRate = hSignalsOut.SimulinkRate;
pircore.getLogicComp( hN, hSignalsIn, opSignal, op, compName, desc, slHandle );
logicComp = pirelab.getDTCComp( hN, opSignal, hSignalsOut, 'Floor', 'Wrap', 'SI' );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSFJVRc.p.
% Please follow local copyright laws when handling this file.

