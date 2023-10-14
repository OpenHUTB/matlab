function varargout = shared( level, varargin )
arguments
    level( 1, 1 )coderapp.internal.log.LogLevel = 'debug'
end
arguments( Repeating )
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


