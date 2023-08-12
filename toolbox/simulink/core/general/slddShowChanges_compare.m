function slddShowChanges_compare( varargin )





leftEntryIDStr = varargin{ 2 };
leftEntryID = str2num( varargin{ 2 } );
if nargin > 2
rightEntryIDStr = varargin{ 3 };
else 
rightEntryIDStr = leftEntryIDStr;
end 
rightEntryID = str2num( rightEntryIDStr );

vs1Str = [ 'slddEvaluate(''', varargin{ 1 }, ''', ', leftEntryIDStr, ', false)' ];
vs2Str = [ 'slddEvaluate(''', varargin{ 1 }, ''', ', rightEntryIDStr, ', true)' ];

vs1 = comparisons.internal.var.makeVariableSource( slddVarName( varargin{ 1 }, leftEntryID, false ), vs1Str );
vs2 = comparisons.internal.var.makeVariableSource( slddVarName( varargin{ 1 }, rightEntryID, true ), vs2Str );

comparisons.internal.var.startComparison( vs1, vs2 );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRLX_LI.p.
% Please follow local copyright laws when handling this file.

