function [ varargout ] = execv2( varargin )











execv2FN = 'EnableSLExecSimBridge';
execv2OFV = slfeature( execv2FN );

if nargin == 0

if nargout > 0
varargout{ 1 } = execv2OFV;
end 
fprintf( '### %s = %d\n', execv2FN, execv2OFV );
return ;

elseif nargin == 1

arg = varargin{ 1 };
if isequal( arg, 'on' )

execv2 = 1;

elseif isequal( arg, '16a' ) || isequal( arg, 'onoff' ) || isequal( arg, '11' )

execv2 = 11;

elseif isequal( arg, 'off' ) || isequal( arg, '15b' )

execv2 = 0;

else 
error( 'invalid usage' );
end 

elseif nargin > 1
error( 'invalid usage' );
end 

slfeature( execv2FN, execv2 );
fprintf( '### %s = %d (%d)\n',  ...
execv2FN, slfeature( execv2FN ), execv2OFV );

if nargout > 0
out{ 1, 1 } = execv2FN;
out{ 1, 2 } = execv2OFV;
varargout{ 1 } = out;
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJx7bgr.p.
% Please follow local copyright laws when handling this file.

