classdef ReadRestriction < lutdesigner.data.restriction.AccessRestriction

properties ( SetAccess = immutable )
Reason
end 

methods 
function this = ReadRestriction( reason )
R36
reason( 1, 1 )message = 'lutdesigner:data:unspecifiedDataSource'
end 
this.Reason = reason;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYUk1Ih.p.
% Please follow local copyright laws when handling this file.

