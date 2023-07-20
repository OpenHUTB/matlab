function out=getCurrentTarget(modelName)




    import Simulink.ModelReference.ProtectedModel.*;
    modelName=Simulink.ModelReference.ProtectedModel.getCharArray(modelName);
    out=CurrentTarget.get(modelName);
end