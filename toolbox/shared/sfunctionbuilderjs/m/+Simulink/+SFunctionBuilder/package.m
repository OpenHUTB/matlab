function package( blkHandle )

arguments
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

