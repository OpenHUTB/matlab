function signalType = setSignalType( this, varargin )




p = inputParser;

p.addParamValue( 'type', '' );
p.addParamValue( 'dim', 1 );
p.addParamValue( 'complex', 0 );

p.parse( varargin{ : } );
signalType = p.Results;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpihqD9i.p.
% Please follow local copyright laws when handling this file.

