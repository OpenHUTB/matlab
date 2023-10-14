function varargout = globalLevel( newLevel )
arguments
    newLevel( 1, 1 )coderapp.internal.log.LogLevel = 'Off'
end

persistent levelCache selfUpdating;
isSet = nargin > 0;


if ~coderapp.internal.log.Logger.HAS_LOGGER_IMPL || ~isempty( selfUpdating )
    if ~isSet
        varargout{ 1 } = coderapp.internal.log.LogLevel.Off;
    end
    return
end

if ~isSet && isempty( levelCache )

    selfUpdating = true;%#ok<NASGU>
    levelCache = coderapp.internal.globalconfig( 'LogLevel' );
    selfUpdating = [  ];
end
if isSet
    levelCache = coderapp.internal.log.LogLevel( newLevel );
    coderapp.internal.globalconfig( '-internalSet', 'LogLevel', newLevel );
else
    varargout{ 1 } = levelCache;
end
end


