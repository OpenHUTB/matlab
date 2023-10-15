function S = splitterTeeS( obj, freq, z0 )

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

splitline = microstripLine;
splitline.Length = ref.SplitLineLength;
splitline.Width = ref.SplitLineWidth;
splitline.Height = ref.Height;
splitline.Substrate = ref.Substrate;
splitline.Conductor = ref.Conductor;
splitline = pcbElement( splitline );

matchline = microstripLine;
matchline.Length = ref.MatchLineLength;
matchline.Width = ref.MatchLineWidth;
matchline.Height = ref.Height;
matchline.Substrate = ref.Substrate;
matchline.Conductor = ref.Conductor;
matchline = pcbElement( matchline );

ckt = circuit( 'behavioral' );
add( ckt, [ 1, 2 ], portline )
add( ckt, [ 2, 3 ], splitline )
add( ckt, [ 2, 4 ], clone( splitline ) )
add( ckt, [ 3, 5 ], matchline )
add( ckt, [ 4, 6 ], clone( matchline ) )
add( ckt, [ 5, 7 ], clone( portline ) )
add( ckt, [ 6, 8 ], clone( portline ) )
setports( ckt, [ 1, 0 ], [ 7, 0 ], [ 8, 0 ], { 'in', 'out1', 'out2' } )
S = sparameters( ckt, freq, z0 );
end

