function out=getVariableNameMapping(modelName,retParamsAndSigs)




    if nargin<2
        retParamsAndSigs=false;
    end
    paramGetter=Simulink.ModelReference.ProtectedModel.ParameterInfoGetter(modelName);

    if retParamsAndSigs
        out=paramGetter.getSignalsAndParams();
    else
        out=paramGetter.get();
    end
end