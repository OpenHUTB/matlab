function out=hasMultipleTargets(modelName)





    import Simulink.ModelReference.ProtectedModel.*;
    targets=getSupportedTargets(modelName);




    out=length(targets)>2;
end