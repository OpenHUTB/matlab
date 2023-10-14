function s = fullSubtract( a, b, canComputeInDouble )

arguments
    a
    b
    canComputeInDouble( 1, 1 )logical =  ...
        fixed.internal.type.isBaseTypeOrSubsetTypeOfDouble( a ) ...
        && fixed.internal.type.isBaseTypeOrSubsetTypeOfDouble( b )
end

if canComputeInDouble

    aIs64BitInt = isa( a, 'int64' ) || isa( a, 'uint64' );
    bIs64BitInt = isa( b, 'int64' ) || isa( b, 'uint64' );
    if ~aIs64BitInt && ~bIs64BitInt
        s = fixed.internal.math.nonFiniteInfo( double( a ), double( b ) );
        a( ~isfinite( double( a ) ) ) = 0;
        b( ~isfinite( double( b ) ) ) = 0;
        valDiff = double( a ) - double( b );
    else


        s = fixed.internal.math.nonFiniteInfo( a, b );


        valDiff = compute64BitIntInDouble( a, b );
    end

    iiNotSameFinite = valDiff ~= 0;
    s.numNotSameFinite = sum( iiNotSameFinite( : ) );
    s.numNotSame = s.numNotSameFinite + s.numNotSameNonFinite;
    s.diffFinite = valDiff;
else

    s = fixed.internal.math.fullSubtract( a, b );
end
end


function y = compute64BitIntInDouble( a, b )

[ aMS, aLS ] = fixed.internal.errorcalculator.getMS_LS( a );
[ bMS, bLS ] = fixed.internal.errorcalculator.getMS_LS( b );

y = ( aMS - bMS ) + ( aLS - bLS );

end


