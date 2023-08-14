function onBack(this,dlg)



    try
        hStep=getStepHandle(this);
        onBack(hStep,dlg);
        clearStatusMessage(this,dlg);
    catch ME
        displayErrorMessage(this,dlg,ME.message);
    end

