function runGenerateRTLCodeAndTestbench( obj, dut )




hModel = obj.getModelName;
hDriver = hdlcoderargs( dut );


hdlset_param( hModel, 'HDLSubsystem', dut );
hDriver.OrigModelName = hModel;
hDriver.OrigStartNodeName = dut;
setupParams( hModel );


obj.saveGenerateHDLSettingToModel( hModel, obj.GenerateRTLCode, obj.GenerateTestbench, obj.GenerateValidationModel );


if ( hdlwfsmartbuild.isSmartbuildOn( 0, hModel ) )
incrementalTopCli = 'on';
else 
incrementalTopCli = 'off';
end 





if isempty( hDriver.OrigModelName )
startNode = dut;
else 
hDriver.ModelName = hDriver.OrigModelName;
hDriver.setStartNodeName( hDriver.OrigStartNodeName );
startNode = hDriver.OrigStartNodeName;
end 

transientCLIs = getAllTransientCLI( obj );
hDriver.makehdl( { 'HDLSubsystem', startNode, 'IncrementalCodeGenForTopModel', incrementalTopCli, 'Backannotation', 'on', transientCLIs{ : } } );




if obj.isGenericWorkflow
obj.hGeneric.hConstraintEmitter.generateConstraintFile;
end 



obj.transientCLIMaps( 'GenerateTB' ) = 'off';
obj.transientCLIMaps( 'GenerateCodeInfo' ) = 'off';

if hdlwfsmartbuild.isSmartbuildOn( 0, hModel ) && obj.isGenericWorkflow



wrapGenSbObj = hdlwfsmartbuild.AsicfpgaWrapGenSb.getInstance( obj );


wrapGenSbObj.preprocess;




wrapGenSbObj.postprocess;
end 

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


function pvs = getAllTransientCLI( hDI )

transientCLIMaps = hDI.transientCLIMaps;
keys = transientCLIMaps.keys;
pvs = cell( 1, length( keys ) * 2 );
for i = 1:length( keys )
pvs{ i * 2 - 1 } = keys{ i };
pvs{ i * 2 } = transientCLIMaps( keys{ i } );
end 

end 









% Decoded using De-pcode utility v1.2 from file /tmp/tmp23VomH.p.
% Please follow local copyright laws when handling this file.

