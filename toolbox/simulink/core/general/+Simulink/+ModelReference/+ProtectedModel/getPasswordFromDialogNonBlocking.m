function getPasswordFromDialogNonBlocking(modelName)





    import Simulink.ModelReference.ProtectedModel.*;

    hiddenFigure=figure('visible','off');
    removeHiddenFigure=onCleanup(@()delete(hiddenFigure));
    getPasswordFromDialogForUnlock(modelName,true,'',true,'',true,hiddenFigure);
end
