classdef WarningState < handle
properties ( SetAccess = private, GetAccess = private )
State
end 


methods ( Access = public )
function this = WarningState(  )
this.State = warning( 'query', 'backtrace' );
end 


function delete( this )
warning( 'backtrace', this.State.state );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpopN3Uk.p.
% Please follow local copyright laws when handling this file.

