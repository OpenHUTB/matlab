function result = getRelativeError( approximateValue, trueValue, bitsOfAccuracy, canComputeInDouble )

















































R36
approximateValue{ mustBeNumericOrLogical }
trueValue{ mustBeNumericOrLogical }
bitsOfAccuracy{ mustBeScalarOrEmpty, mustBePositive, mustBeInteger } = 54
canComputeInDouble( 1, 1 )logical{ mustBeNonempty } =  ...
fixed.internal.type.isBaseTypeOrSubsetTypeOfDouble( approximateValue ) ...
 && fixed.internal.type.isBaseTypeOrSubsetTypeOfDouble( trueValue )
end 

assert( all( size( trueValue ) == size( approximateValue ) ), 'Both inputs must have the same size' );
calculator = fixed.internal.errorcalculator.ErrorCalculatorFactory(  ).getCalculatorForRelativeError(  );
result = calculator.calculate( approximateValue, trueValue, canComputeInDouble, bitsOfAccuracy );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzUSLB5.p.
% Please follow local copyright laws when handling this file.

