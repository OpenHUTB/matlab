function out=getCallbackInfoImpl(protectedModelFile,event,appliesTo)




    import Simulink.ModelReference.ProtectedModel.*;

    narginchk(3,3);

    protectedModelFile=Simulink.ModelReference.ProtectedModel.getCharArray(protectedModelFile);
    event=Simulink.ModelReference.ProtectedModel.getCharArray(event);
    appliesTo=Simulink.ModelReference.ProtectedModel.getCharArray(appliesTo);

    opts=getOptions(protectedModelFile,'runConsistencyChecksNoPlatform');

    if strcmpi(appliesTo,'CODEGEN')
        ci=opts.codeInterface;
        target=getCurrentTarget(opts.modelName);
    else
        ci='';
        target='';
    end


    out=Simulink.ProtectedModel.CallbackInfo(opts.modelName,...
    opts.subModels,...
    event,...
    appliesTo,...
    ci,...
    target);
end