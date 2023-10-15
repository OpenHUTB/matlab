function S = wilkinsonSplitterUnequalS( obj, freq, z0 )

arguments
    obj( 1, 1 )
    freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
    z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end


rfpcb.internal.behavioral.ValidateObjectForBehavioral( obj, freq );
rfpcb.internal.behavioral.ValidateSubstrateForBehavioral( obj );



TotalHeight = max( sum( obj.Substrate.Thickness ), obj.Height );
ratio1 = min( [ obj.PortLineWidth / TotalHeight, obj.SplitLineWidth / TotalHeight, obj.MatchLineWidth / TotalHeight ] );
ratio2 = max( [ obj.PortLineWidth / TotalHeight, obj.SplitLineWidth / TotalHeight, obj.MatchLineWidth / TotalHeight ] );
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

splitline1 = microstripLine;
splitline1.Length = ref.SplitLineLength;
splitline1.Width = ref.SplitLineWidth( 1 );
splitline1.Height = ref.Height;
splitline1.Substrate = ref.Substrate;
splitline1.Conductor = ref.Conductor;
splitline1 = pcbElement( splitline1 );

splitline2 = microstripLine;
splitline2.Length = ref.SplitLineLength;
splitline2.Width = ref.SplitLineWidth( 2 );
splitline2.Height = ref.Height;
splitline2.Substrate = ref.Substrate;
splitline2.Conductor = ref.Conductor;
splitline2 = pcbElement( splitline2 );

matchline1 = microstripLine;
matchline1.Length = ref.MatchLineLength;
matchline1.Width = ref.MatchLineWidth( 1 );
matchline1.Height = ref.Height;
matchline1.Substrate = ref.Substrate;
matchline1.Conductor = ref.Conductor;
matchline1 = pcbElement( matchline1 );

matchline2 = microstripLine;
matchline2.Length = ref.MatchLineLength;
matchline2.Width = ref.MatchLineWidth( 2 );
matchline2.Height = ref.Height;
matchline2.Substrate = ref.Substrate;
matchline2.Conductor = ref.Conductor;
matchline2 = pcbElement( matchline2 );

res1 = ref.Resistance;

ckt = circuit( 'behavioral' );
add( ckt, [ 1, 2 ], portline );
add( ckt, [ 2, 3 ], splitline1 );
add( ckt, [ 2, 4 ], clone( splitline2 ) );
add( ckt, [ 3, 5 ], matchline1 );
add( ckt, [ 4, 6 ], clone( matchline2 ) );
add( ckt, [ 5, 7 ], clone( portline ) );
add( ckt, [ 6, 8 ], clone( portline ) );
add( ckt, [ 3, 4 ], resistor( res1 ) );
setports( ckt, [ 1, 0 ], [ 7, 0 ], [ 8, 0 ], { 'in', 'out1', 'out2' } );

S = sparameters( ckt, freq, z0 );
end

