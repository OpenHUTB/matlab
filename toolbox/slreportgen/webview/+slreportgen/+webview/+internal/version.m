function out = version( in )



R36
in double = [  ]
end 

persistent VERSION

if isempty( VERSION )
VERSION = 3;
end 

if ~isempty( in )
VERSION = in;
end 

out = VERSION;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHTiczd.p.
% Please follow local copyright laws when handling this file.

