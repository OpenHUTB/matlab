function varargout = simplot( varargin )





















if nargin == 1 && isstruct( varargin{ 1 } )
varargin{ 2 } = inputname( 1 );
end 

ret = cell( 1, nargout );
[ ret{ : } ] = Simulink.sdi.plot( varargin{ : } );
varargout = ret;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpeniqIF.p.
% Please follow local copyright laws when handling this file.

