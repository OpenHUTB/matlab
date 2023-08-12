function package( blkHandle )




R36
blkHandle
end 

blkHandle = Simulink.SFunctionBuilder.internal.verifyBlockHandle( blkHandle );
applicationData = Simulink.SFunctionBuilder.internal.getApplicationData( blkHandle );

cliView = struct( 'publishChannel', 'cli' );
sfcnmodel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );
sfcnmodel.registerView( blkHandle, cliView );
sfunctionwizard( blkHandle, 'doPackage', applicationData );

sfcnmodel.unregisterView( blkHandle, cliView );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpAvyz6U.p.
% Please follow local copyright laws when handling this file.

