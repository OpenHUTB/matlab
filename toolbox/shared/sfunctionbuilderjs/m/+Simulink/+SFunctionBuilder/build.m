function buildLog = build( blockHandle )




R36
blockHandle
end 

blockHandle = Simulink.SFunctionBuilder.internal.verifyBlockHandle( blockHandle );

sfcnmodel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );

cliView = struct( 'publishChannel', 'cli' );
sfcnmodel.registerView( blockHandle, cliView );

controller = sfunctionbuilder.internal.sfunctionbuilderController.getInstance;

option = struct( 'optionName', 'SaveCodeOnly', 'optionSelected', false );
controller.updateSFunctionBuildOption( blockHandle, option );
if nargout > 0
buildLog = controller.doBuild( blockHandle );
else 
controller.doBuild( blockHandle );
end 

sfcnmodel.unregisterView( blockHandle, cliView );


end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNUgBB4.p.
% Please follow local copyright laws when handling this file.

