function notval = notbool( val )






if ( isstr( val ) ), 

if ( strcmp( val, 'yes' ) ), 
notval = 'no';return ;
end 

if ( strcmp( val, 'no' ) ), 
notval = 'yes';return ;
end 

if ( strcmp( val, 'on' ) ), 
notval = 'off';return ;
end 

if ( strcmp( val, 'off' ) ), 
notval = 'on';return ;
end 

else , 

notval = ~val;

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIGdzS5.p.
% Please follow local copyright laws when handling this file.

