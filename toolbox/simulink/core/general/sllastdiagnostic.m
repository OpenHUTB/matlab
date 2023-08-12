function diag = sllastdiagnostic( newDiag )























if nargin == 0, 
diag = get_param( 0, 'LastDiagnostic' );
else 



if ~isempty( newDiag ), 
type = { newDiag( : ).Type };
type( find( strcmp( type, 'error' ) ) ) = [  ];
type( find( strcmp( type, 'warning' ) ) ) = [  ];
if ~isempty( type ), 
DAStudio.error( 'Simulink:util:LastDiagnositcBadDiagStructType' );
end 
end 

set_param( 0, 'LastDiagnostic', newDiag );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpACYR0W.p.
% Please follow local copyright laws when handling this file.

