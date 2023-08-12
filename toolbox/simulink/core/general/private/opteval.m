function [ f, g, msg ] = opteval( x, FUNfcns, varargin )












f = [  ];
g = [  ];
msg = '';

switch FUNfcns{ 4 }
case { 'trim', 'ncdtoolbox' }
if FUNfcns{ 3 } == 1
[ f, g ] = feval( FUNfcns{ 1 }, x, varargin{ : } );
elseif FUNfcns{ 3 } == 2
f = feval( FUNfcns{ 1 }, x, varargin{ : } );
if ~isempty( FUNfcns{ 2 } )
g = feval( FUNfcns{ 2 }, x, varargin{ : } );
end 
end 
otherwise 
msg = getString( message( 'Simulink:util:CallingFunctionNotKnown' ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpoCtoH_.p.
% Please follow local copyright laws when handling this file.

