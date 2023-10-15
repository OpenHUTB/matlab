function buildLog = build( blockHandle )

arguments
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

