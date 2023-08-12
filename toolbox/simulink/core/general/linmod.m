function varargout = linmod( model, varargin )






















































Ts = 0;
Args = 'IgnoreDiscreteStates';

[ varargout{ 1:max( 1, nargout ) } ] = dlinmod( model, Ts, varargin{ : }, Args );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDn5hk5.p.
% Please follow local copyright laws when handling this file.

