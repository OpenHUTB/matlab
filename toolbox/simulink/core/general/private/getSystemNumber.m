function out = getSystemNumber( block )




h = get_param( block, 'Object' );
sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );
if isa( h, 'Simulink.SubSystem' )
try 
out = h.getSystemNumber(  );
catch 
out = [  ];
end 
else 
out = [  ];
end 
delete( sess );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpRCLFo3.p.
% Please follow local copyright laws when handling this file.

