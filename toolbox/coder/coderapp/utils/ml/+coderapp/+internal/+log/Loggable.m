classdef ( Abstract )Loggable < handle





properties ( SetAccess = protected, Hidden )
Logger coderapp.internal.log.Logger{ mustBeScalarOrEmpty( Logger ) } = coderapp.internal.log.DummyLogger.empty(  )
end 

properties ( Dependent, Hidden )
LogLevel
end 

methods 
function set.LogLevel( this, logLevel )
R36
this
logLevel( 1, 1 )uint32
end 

if ~isempty( this.Logger )
this.Logger.Level = logLevel;
end 
end 

function level = get.LogLevel( this )
if ~isempty( this.Logger )
level = this.Logger.Level;
else 
level = [  ];
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp9xQTn_.p.
% Please follow local copyright laws when handling this file.

