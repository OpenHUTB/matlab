function applicationData = getApplicationData( blockHandle )



R36
blockHandle
end 
blockHandle = Simulink.SFunctionBuilder.internal.verifyBlockHandle( blockHandle );
sfcnmodel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );
try 
applicationData = sfcnmodel.getApplicationData( blockHandle );
catch 
Simulink.SFunctionBuilder.internal.setup( blockHandle );
applicationData = sfcnmodel.getApplicationData( blockHandle );
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpUQKCcH.p.
% Please follow local copyright laws when handling this file.

