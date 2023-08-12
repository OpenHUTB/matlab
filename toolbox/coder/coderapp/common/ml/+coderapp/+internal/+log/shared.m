function varargout = shared( level, varargin )
R36
level( 1, 1 )coderapp.internal.log.LogLevel = 'debug'
end 
R36( Repeating )
varargin
end 




persistent sharedLogger;
if isempty( sharedLogger ) || ~isvalid( sharedLogger )
sharedLogger = coderapp.internal.log.new( Id = 'shared', Locked = true );
end 

if nargin == 0
varargout{ 1 } = sharedLogger;
elseif nargout ~= 0
varargout{ 1 } = sharedLogger.log( level, varargin{ : } );
else 
sharedLogger.log( level, varargin{ : } );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpsEEctN.p.
% Please follow local copyright laws when handling this file.

