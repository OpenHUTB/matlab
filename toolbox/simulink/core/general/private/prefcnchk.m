function [ allfcns, msg ] = prefcnchk( funstr, caller, lenVarIn )


















msg = '';
allfcns = {  };
funfcn = [  ];
confcn = [  ];
strtype = 1;

switch caller
case { 'ncdtoolbox', 'trim' }
[ funfcn, msg ] = fcnchk( funstr, lenVarIn );
if ~isempty( msg )
return 
end 
confcn = [  ];
if isa( funfcn, 'inline' )
msg = getString( message( 'Simulink:util:ExpressionSyntaxNotSupportedForTrim' ) );
return 
end 
allfcns{ 1 } = funfcn;
allfcns{ 4 } = caller;
allfcns{ 3 } = strtype;
allfcns{ 2 } = confcn;
otherwise 
disp( getString( message( 'Simulink:util:UnknownCallerInPrefcnchkCall' ) ) )
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmproWW0M.p.
% Please follow local copyright laws when handling this file.

