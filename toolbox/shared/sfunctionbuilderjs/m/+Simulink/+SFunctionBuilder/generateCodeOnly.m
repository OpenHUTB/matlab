function buildLog = generateCodeOnly( blockHandle )




R36
blockHandle
end 

blockHandle = Simulink.SFunctionBuilder.internal.verifyBlockHandle( blockHandle );

sfcnmodel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );

cliView = struct( 'publishChannel', 'cli' );
sfcnmodel.registerView( blockHandle, cliView );

controller = sfunctionbuilder.internal.sfunctionbuilderController.getInstance;

option = struct( 'optionName', 'SaveCodeOnly', 'optionSelected', true );
controller.updateSFunctionBuildOption( blockHandle, option );
if nargout > 0
buildLog = controller.doBuild( blockHandle );
else 
controller.doBuild( blockHandle );
end 

sfcnmodel.unregisterView( blockHandle, cliView );


end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_NWaeP.p.
% Please follow local copyright laws when handling this file.

