classdef InterfaceFunctionGetter








properties ( Hidden, Constant )





InstrumentInterfaces( 1, : )string =  ...
[ "udpport", "visadev", "tcpserver" ]

DefaultFcn = @(  )[  ]
InstrumentLicenseFcn = @instrument.internal.InstrumentBaseClass.attemptLicenseCheckout
end 

methods ( Hidden, Static )
function fcn = getLicenseFcn( interfaceName )













R36
interfaceName string
end 

if isempty( interfaceName ) ||  ...
~ismember( interfaceName, instrument.internal.InterfaceFunctionGetter.InstrumentInterfaces )
fcn = instrument.internal.InterfaceFunctionGetter.DefaultFcn;
else 
fcn = instrument.internal.InterfaceFunctionGetter.InstrumentLicenseFcn;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpve9lbu.p.
% Please follow local copyright laws when handling this file.

