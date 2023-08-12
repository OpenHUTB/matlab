function runGenerateRTLCode( obj, dut )




hModel = obj.getModelName;
hDriver = hdlcoderargs( dut );


hdlset_param( hModel, 'HDLSubsystem', dut );
hDriver.OrigModelName = hModel;
hDriver.OrigStartNodeName = dut;
setupParams( hModel );

hdlset_param( hModel, 'GenerateHDLCode', 'on' );
hdlset_param( hModel, 'GenerateCosimModel', 'none' );
obj.transientCLIMaps( 'GenerateTB' ) = 'off';
hdlset_param( hModel, 'GenerateValidationModel', 'off' );



hDriver.makehdlturnkey;

obj.transientCLIMaps( 'GenerateCodeInfo' ) = 'off';


end 

function setupParams( mdlName )



try 
hcc = gethdlcc( mdlName );



hcc.createCLI;

catch me
if hdlgetparameter( 'debug' ) > 1
rethrow( me );
end 
end 





end 












% Decoded using De-pcode utility v1.2 from file /tmp/tmpTRrZRA.p.
% Please follow local copyright laws when handling this file.

