function result = getAbsoluteError( approximateValue, trueValue, canComputeInDouble )











































R36
approximateValue
trueValue
canComputeInDouble( 1, 1 )logical =  ...
fixed.internal.type.isBaseTypeOrSubsetTypeOfDouble( approximateValue ) ...
 && fixed.internal.type.isBaseTypeOrSubsetTypeOfDouble( trueValue )
end 

assert( all( size( trueValue ) == size( approximateValue ) ), 'Both inputs must have the same size' );
calculator = fixed.internal.errorcalculator.ErrorCalculatorFactory(  ).getCalculatorForAbsoluteError(  );
result = calculator.calculate( approximateValue, trueValue, canComputeInDouble );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7Yqczn.p.
% Please follow local copyright laws when handling this file.

