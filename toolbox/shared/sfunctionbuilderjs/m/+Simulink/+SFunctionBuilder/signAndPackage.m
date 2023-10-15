function signAndPackage( blkHandle, certificatePath )

arguments
    blkHandle
    certificatePath( 1, : )char
end

blkHandle = Simulink.SFunctionBuilder.internal.verifyBlockHandle( blkHandle );
applicationData = Simulink.SFunctionBuilder.internal.getApplicationData( blkHandle );
applicationData.SfunWizardData.SignPackage = '1';
applicationData.SfunWizardData.CertificateName = certificatePath;

cliView = struct( 'publishChannel', 'cli' );
sfcnmodel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );
sfcnmodel.registerView( blkHandle, cliView );
sfunctionwizard( blkHandle, 'doPackage', applicationData );

sfcnmodel.unregisterView( blkHandle, cliView );


end
