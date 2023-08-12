function slregistercapabilities( showCaps )








if nargin > 0
doShowCaps = showCaps == true;
else 
doShowCaps = false;
end 



prodKeys = { 'comm', 'dsp', 'Simulink', 'vision' };

for i = 1:length( prodKeys )
prodKey = prodKeys{ i };

if doShowCaps
disp( DAStudio.message( 'Simulink:dialog:SearchProduct', prodKey ) );
end 


capStringMsg = [ prodKey, ':bcst:bcstCapabilities' ];
try 

[ newCaps, capId ] = DAStudio.message( capStringMsg );
catch e

newCaps = '';
capId = e.identifier;
end 



while length( newCaps ) > 0
[ split ] = regexp( newCaps, '^ *([a-zA-Z][a-zA-Z0-9]*)([, ]*|)(.*)$', 'tokens' );
oneCap = split{ 1 }{ 1 };
newCaps = split{ 1 }{ 3 };
Capabilities.registerCapabilityName( oneCap );
if doShowCaps
disp( sprintf( '%s: %s', prodKey, oneCap ) );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp62V8Wg.p.
% Please follow local copyright laws when handling this file.

