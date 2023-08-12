function slddCompareItems( ddPath, varID_Left, varID_Right )






entry_IDStr = num2str( varID_Left );
entry2_IDStr = num2str( varID_Right );
vs1Str = [ 'slddEvaluate(''', ddPath, ''', ', entry_IDStr, ', true)' ];
vs2Str = [ 'slddEvaluate(''', ddPath, ''', ', entry2_IDStr, ', true)' ];

vs1 = comparisons.internal.var.makeVariableSource( slddVarName( ddPath, varID_Left, true ), vs1Str );
vs2 = comparisons.internal.var.makeVariableSource( slddVarName( ddPath, varID_Right, true ), vs2Str );

comparisons.internal.var.startComparison( vs1, vs2 )

% Decoded using De-pcode utility v1.2 from file /tmp/tmpAtvRvz.p.
% Please follow local copyright laws when handling this file.

