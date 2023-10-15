function S = couplerBranchlineS( obj, freq, z0 )

arguments
    obj( 1, 1 )
    freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
    z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end


rfpcb.internal.behavioral.ValidateObjectForBehavioral( obj, freq );
rfpcb.internal.behavioral.ValidateSubstrateForBehavioral( obj );



TotalHeight = max( sum( obj.Substrate.Thickness ), obj.Height );
ratio1 = min( [ obj.PortLineWidth / TotalHeight, obj.SeriesArmWidth / TotalHeight, obj.ShuntArmWidth / TotalHeight ] );
ratio2 = max( [ obj.PortLineWidth / TotalHeight, obj.SeriesArmWidth / TotalHeight, obj.ShuntArmWidth / TotalHeight ] );
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

seriesarm = microstripLine;
seriesarm.Length = ref.SeriesArmLength;
seriesarm.Width = ref.SeriesArmWidth;
seriesarm.Height = ref.Height;
seriesarm.Substrate = ref.Substrate;
seriesarm.Conductor = ref.Conductor;
seriesarm = pcbElement( seriesarm );

shuntarm = microstripLine;
shuntarm.Length = ref.ShuntArmLength;
shuntarm.Width = ref.ShuntArmWidth;
shuntarm.Height = ref.Height;
shuntarm.Substrate = ref.Substrate;
shuntarm.Conductor = ref.Conductor;
shuntarm = pcbElement( shuntarm );

ckt = circuit( 'behavioral' );
add( ckt, [ 1, 2 ], portline )
add( ckt, [ 2, 3 ], seriesarm )
add( ckt, [ 3, 4 ], clone( portline ) )
add( ckt, [ 5, 6 ], clone( portline ) )
add( ckt, [ 6, 7 ], clone( seriesarm ) )
add( ckt, [ 7, 8 ], clone( portline ) )
add( ckt, [ 2, 6 ], clone( shuntarm ) )
add( ckt, [ 3, 7 ], clone( shuntarm ) )
setports( ckt, [ 1, 0 ], [ 4, 0 ], [ 5, 0 ], [ 8, 0 ], { 'in', 'out1', 'out2', 'out3' } )

S = sparameters( ckt, freq, z0 );
end

