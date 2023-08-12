function outbool = onoff( input )












if ischar( input ), 

switch ( input ), 

case 'on', 
outbool = 1;

case 'off', 
outbool = 0;

case 'yes', 
outbool = 'on';

case 'no', 
outbool = 'off';

otherwise , 
DAStudio.error( 'Simulink:utility:onOffInvInputArgs' );
end 

else 

onoffs = { 'off', 'on' };
outbool = onoffs{ input + 1 };

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpywFH2Z.p.
% Please follow local copyright laws when handling this file.

