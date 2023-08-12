function S = wilkinsonSplitterS( obj, freq, z0 )




R36
obj( 1, 1 )
freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end 


rfpcb.internal.behavioral.ValidateObjectForBehavioral( obj, freq );
rfpcb.internal.behavioral.ValidateSubstrateForBehavioral( obj );



TotalHeight = max( sum( obj.Substrate.Thickness ), obj.Height );
ratio1 = min( [ obj.PortLineWidth / TotalHeight, obj.SplitLineWidth / TotalHeight ] );
ratio2 = max( [ obj.PortLineWidth / TotalHeight, obj.SplitLineWidth / TotalHeight ] );
if ~( isempty( ratio1 ) || isempty( ratio2 ) )
if ( ratio2 > 20 ) || ( ratio1 < 0.05 )
error( message( 'rfpcb:rfpcberrors:WidthHeightLimit', '' ) );
end 
end 

portline = microstripLine;
ref = obj;
portline.Length = ref.PortLineLength;
portline.Width = ref.PortLineWidth;
portline.Height = ref.Height;
portline.Substrate = ref.Substrate;
portline.Conductor = ref.Conductor;
portline = pcbElement( portline );

splitline = microstripLine;
splitline.Length = ref.SplitLineLength;
splitline.Width = ref.SplitLineWidth;
splitline.Height = ref.Height;
splitline.Substrate = ref.Substrate;
splitline.Substrate = ref.Substrate;
splitline = pcbElement( splitline );

res1 = ref.Resistance;

ckt = circuit( 'behavioral' );
add( ckt, [ 1, 2 ], portline );
add( ckt, [ 2, 3 ], splitline );
add( ckt, [ 2, 4 ], clone( splitline ) );
add( ckt, [ 3, 5 ], clone( portline ) );
add( ckt, [ 4, 6 ], clone( portline ) );
add( ckt, [ 3, 4 ], resistor( res1 ) );
setports( ckt, [ 1, 0 ], [ 5, 0 ], [ 6, 0 ], { 'in', 'out1', 'out2' } );
S = sparameters( ckt, freq, z0 );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpF6iEyV.p.
% Please follow local copyright laws when handling this file.

