function setTargetLanguage( blockHandle, language )

arguments
    blockHandle
    language( 1, : )char{ mustBeMember( language, { 'inherit', 'cpp', 'c' } ) }
end

blockHandle = Simulink.SFunctionBuilder.internal.verifyBlockHandle( blockHandle );
sfcnmodel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );

cliView = struct( 'publishChannel', 'cli' );
sfcnmodel.registerView( blockHandle, cliView );
controller = sfunctionbuilder.internal.sfunctionbuilderController.getInstance;
controller.updateSFunctionLanguage( blockHandle, language );


sfcnmodel.unregisterView( blockHandle, cliView );
end

