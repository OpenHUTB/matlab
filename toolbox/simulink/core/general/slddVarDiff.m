function slddVarDiff( varargin )





entryIDStr = num2str( varargin{ 2 } );
vs1Str = [ 'slddEvaluate(''', varargin{ 1 }, ''', ', entryIDStr, ', true)' ];
vs2Str = [ 'slddEvaluate(''', varargin{ 1 }, ''', ', entryIDStr, ', false)' ];

vs1 = comparisons.internal.var.makeVariableSource( slddVarName( varargin{ : }, true ), vs1Str );
vs2 = comparisons.internal.var.makeVariableSource( slddVarName( varargin{ : }, false ), vs2Str );

comparisons.internal.var.startComparison( vs1, vs2 )

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgQLDjM.p.
% Please follow local copyright laws when handling this file.

