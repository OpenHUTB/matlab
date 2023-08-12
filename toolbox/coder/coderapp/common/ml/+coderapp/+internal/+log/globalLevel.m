
function varargout = globalLevel( newLevel )
R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmptDEno6.p.
% Please follow local copyright laws when handling this file.

