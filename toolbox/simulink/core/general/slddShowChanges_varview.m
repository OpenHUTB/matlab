function slddShowChanges_varview( filename, entrykey, usecurrentvalue )




entryID = str2num( entrykey );
blankentry = '''''';

if isequal( usecurrentvalue, 'left' )
b_usecurrentvalue = '0';
else 
b_usecurrentvalue = '1';
end 
varname = slddVarName( filename, entryID, str2num( b_usecurrentvalue ) );

vs1Str = [ 'slddEvaluate(''', filename, ''', ', entrykey, ', ', b_usecurrentvalue, ')' ];
vs2Str = [ 'slddEvaluate(''', filename, ''', ', blankentry, ', ', b_usecurrentvalue, ')' ];

vs1 = comparisons.internal.var.makeVariableSource( varname, vs1Str );
vs2 = comparisons.internal.var.makeVariableSource( varname, vs2Str );

comparisons.internal.var.startComparison( vs1, vs2 );




end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpr2gThN.p.
% Please follow local copyright laws when handling this file.

