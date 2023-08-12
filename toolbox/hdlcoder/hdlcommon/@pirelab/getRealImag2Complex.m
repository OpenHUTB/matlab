function ri2cComp = getRealImag2Complex( hN, hInSignals, hOutSignals,  ...
inputTypeMode, cval, compName, rndMode, satMode )




if ( nargin < 8 )
satMode = 'Wrap';
end 

if ( nargin < 7 )
rndMode = 'Floor';
end 

if ( nargin < 6 )
compName = 'reim2cplx';
end 

if ( nargin < 5 )
cval = 0;
end 

if ( nargin < 4 )
inputTypeMode = 'Real and imag';
end 

switch lower( inputTypeMode )
case 'real and imag'
mode = 1;
case 'real'
mode = 2;
case 'imag'
mode = 3;
otherwise 
mode = inputTypeMode;
end 

tp1 = hInSignals( 1 ).Type;

if numel( hInSignals ) > 1
tp2 = hInSignals( 2 ).Type;

if ~tp1.BaseType.isEqual( tp2.BaseType )
if tp1.BaseType.isFloatType ~= tp2.BaseType.isFloatType
error( message( 'hdlcoder:validate:RealImag2ComplexMixedType' ) );
end 

if tp1.getDimensions ~= tp2.getDimensions
error( message( 'hdlcoder:validate:RealImag2ComplexMixedDimensions' ) );
end 
dtcOutSig = hN.addSignal( hInSignals( 1 ).Type, 'ri2c_in2' );
dtcOutSig.SimulinkRate = hInSignals( 2 ).SimulinkRate;
pirelab.getDTCComp( hN, hInSignals( 2 ), dtcOutSig, rndMode, satMode );
hInSignals = [ hInSignals( 1 ), dtcOutSig ];
end 
end 









if ( ( mode == 2 || mode == 3 ) )
scalarize_con = ( ~isscalar( tp1.getDimensions ) || ( isscalar( tp1.getDimensions ) && ( ~( tp1.getDimensions == 1 ) ) ) );
if ( scalarize_con )
if all( cval( : ) == cval( 1 ) )

cval = cval( 1 );
ri2cComp = pircore.getRealImag2Complex( hN, hInSignals, hOutSignals, mode, cval, compName );
else 
constantInput = hN.addSignal( hInSignals( 1 ).Type, [ compName, '_input2' ] );
constantInput.SimulinkRate = hInSignals( 1 ).SimulinkRate;
cval = pirelab.getValueWithType( cval, hInSignals( 1 ).Type );
pirelab.getConstComp( hN, constantInput, cval );
if mode == 2
Insignals = [ hInSignals, constantInput ];
else 
Insignals = [ constantInput, hInSignals ];
end 
mode = 1;

cval = pirelab.getValueWithType( 0, hInSignals( 1 ).Type );
ri2cComp = pircore.getRealImag2Complex( hN, Insignals, hOutSignals, mode, cval, compName );
end 
else 
cval = pirelab.getValueWithType( cval, hInSignals( 1 ).Type );
ri2cComp = pircore.getRealImag2Complex( hN, hInSignals, hOutSignals, mode, cval, compName );
end 
else 
cval = pirelab.getValueWithType( cval, hInSignals( 1 ).Type );
ri2cComp = pircore.getRealImag2Complex( hN, hInSignals, hOutSignals, mode, cval, compName );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqe3KfG.p.
% Please follow local copyright laws when handling this file.

