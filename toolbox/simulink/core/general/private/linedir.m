function direct = linedir( layout )







if layout( 1, 2 ) == layout( 2, 2 )

if layout( 1, 1 ) < layout( 2, 1 )
direct = 0;
else 
direct = 2;
end ;
elseif layout( 1, 1 ) == layout( 2, 1 )

if layout( 1, 2 ) < layout( 2, 2 )
direct = 1;
else 
direct = 3;
end ;
else 

direct =  - 1;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpkp2nvN.p.
% Please follow local copyright laws when handling this file.

