function removeTarget(filename,target)




    import Simulink.ModelReference.ProtectedModel.*;
    if~(ischar(target)||isstring(target))
        DAStudio.error('Simulink:protectedModel:InvalidTargetName');
    end
    remover=TargetRemover(getCharArray(filename),getCharArray(target));
    remover.protect();
end