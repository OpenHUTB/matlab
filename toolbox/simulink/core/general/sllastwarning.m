function warns = sllastwarning( newWarns )























if nargin == 0, 

warns = get_param( 0, 'LastWarning' );

else 




if ~isempty( newWarns ), 
isSetProperly = true;
if isstruct( newWarns )
if ~isequal( sort( fieldnames( newWarns ) ),  ...
{ 'Handle';'Message';'MessageID';'Type' } )
isSetProperly = false;
end 
if isSetProperly && ( ~all( strcmp( { newWarns( : ).Type }, 'warning' ) ) )
isSetProperly = false;
end 
else 
isSetProperly = false;
end 

if ~isSetProperly
error( message( 'Simulink:util:InvalidDiagnosticType', 'warning' ) );
end 
end 
set_param( 0, 'LastWarning', newWarns );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXMyQPB.p.
% Please follow local copyright laws when handling this file.

