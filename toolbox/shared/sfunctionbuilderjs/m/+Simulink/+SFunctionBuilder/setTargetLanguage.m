function setTargetLanguage( blockHandle, language )




R36
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpQuBlnI.p.
% Please follow local copyright laws when handling this file.

