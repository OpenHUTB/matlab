function state = log( newState )












R36
newState logical = logical.empty(  );
end 

persistent STATE

mlock(  );
if isempty( STATE )
STATE = false;
end 

state = STATE;
if ~isempty( newState )
STATE = newState;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpM1s9OR.p.
% Please follow local copyright laws when handling this file.

