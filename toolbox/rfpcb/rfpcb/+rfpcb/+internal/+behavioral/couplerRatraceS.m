function S = couplerRatraceS( obj, freq, z0 )




R36
obj( 1, 1 )
freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end 


rfpcb.internal.behavioral.ValidateObjectForBehavioral( obj, freq );
rfpcb.internal.behavioral.ValidateSubstrateForBehavioral( obj );



TotalHeight = max( sum( obj.Substrate.Thickness ), obj.Height );
ratio1 = min( [ obj.PortLineWidth / TotalHeight, obj.CouplerLineWidth / TotalHeight ] );
ratio2 = max( [ obj.PortLineWidth / TotalHeight, obj.CouplerLineWidth / TotalHeight ] );
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

seriesarm1 = microstripLine;
seriesarm1.Length = ref.Circumference / 6;
seriesarm1.Width = ref.CouplerLineWidth;
seriesarm1.Height = ref.Height;
seriesarm1.Substrate = ref.Substrate;
seriesarm1.Substrate = ref.Substrate;
seriesarm1 = pcbElement( seriesarm1 );

seriesarm2 = microstripLine;
seriesarm2.Length = 3 * ref.Circumference / 6;
seriesarm2.Width = ref.CouplerLineWidth;
seriesarm2.Height = ref.Height;
seriesarm2.Substrate = ref.Substrate;
seriesarm2.Substrate = ref.Substrate;
seriesarm2 = pcbElement( seriesarm2 );

ckt = circuit( 'behavioral' );
add( ckt, [ 1, 2 ], portline );
add( ckt, [ 2, 3 ], seriesarm1 );
add( ckt, [ 3, 4 ], clone( seriesarm1 ) );
add( ckt, [ 4, 5 ], clone( seriesarm1 ) );
add( ckt, [ 2, 5 ], clone( seriesarm2 ) );
add( ckt, [ 3, 6 ], clone( portline ) );
add( ckt, [ 4, 7 ], clone( portline ) );
add( ckt, [ 5, 8 ], clone( portline ) );
setports( ckt, [ 1, 0 ], [ 6, 0 ], [ 7, 0 ], [ 8, 0 ], { 'in', 'out1', 'out2', 'out3' } );
S = sparameters( ckt, freq, z0 );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpn9ASzR.p.
% Please follow local copyright laws when handling this file.

