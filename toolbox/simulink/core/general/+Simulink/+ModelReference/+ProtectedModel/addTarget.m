function addTarget(modelName)




    import Simulink.ModelReference.ProtectedModel.*;
    aTargetAdder=TargetAdder(getCharArray(modelName));
    aTargetAdder.protect();
end