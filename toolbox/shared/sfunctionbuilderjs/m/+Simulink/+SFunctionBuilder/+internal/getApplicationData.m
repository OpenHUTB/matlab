function applicationData = getApplicationData( blockHandle )

arguments
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


