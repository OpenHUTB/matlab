function errs = sllasterror( newErrs )























if nargin == 0, 

errs = get_param( 0, 'LastError' );

else 





if ~isempty( newErrs ), 
isSetProperly = true;
if isstruct( newErrs )
if ~isequal( sort( fieldnames( newErrs ) ),  ...
{ 'Handle';'Message';'MessageID';'Type' } )
isSetProperly = false;
end 
if isSetProperly && ( ~all( strcmp( { newErrs( : ).Type }, 'error' ) ) )
isSetProperly = false;
end 
else 
isSetProperly = false;
end 

if ~isSetProperly
error( message( 'Simulink:util:InvalidDiagnosticType', 'error' ) );
end 
end 
set_param( 0, 'LastError', newErrs );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUNmf8L.p.
% Please follow local copyright laws when handling this file.

