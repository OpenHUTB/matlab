function out=supportsAccel(opts)





    out=Simulink.ModelReference.ProtectedModel.supportsCodeGen(opts)||...
    strcmp(opts.modes,'Accelerator');

end

