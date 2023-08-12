function validateArchitectureType( type )







validateattributes( type, { 'char', 'string' }, { 'row' }, '', 'ARCHITECTURETYPE', 2 );

validTypes = { 'Architecture', 'SoftwareArchitecture', 'AutosarArchitecture' };
validTypeMsg = [ '''', validTypes{ 1 }, ''', ''', validTypes{ 2 }, ''', ''', validTypes{ 3 }, '''' ];

if ~any( strcmpi( type, validTypes ) )
error( message( 'SystemArchitecture:API:InvalidArchitectureType', type, validTypeMsg ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmprkwdce.p.
% Please follow local copyright laws when handling this file.

