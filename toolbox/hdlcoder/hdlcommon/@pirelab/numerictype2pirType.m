function pirT = numerictype2pirType( nt )



































ntInternal = fixed.internal.type.extractNumericType( nt );


if isfloat( ntInternal )
pirT = floatNumericType2Pir( ntInternal );
else 
pirT = fixedNumericType2Pir( ntInternal );
end 

end 


function pirT = floatNumericType2Pir( ntInternal )

switch ( ntInternal.DataType )
case 'half'
pirT = pir_half_t(  );
case 'single'
pirT = pir_single_t(  );
case 'double'
pirT = pir_double_t(  );
otherwise 

assert( 'Unknown floating-point type' );
end 
end 

function pirT = fixedNumericType2Pir( ntInternal )


pirT = pir_fixpt_t( ntInternal.SignednessBool, ntInternal.WordLength, ntInternal.FixedExponent );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpR4zKo2.p.
% Please follow local copyright laws when handling this file.

