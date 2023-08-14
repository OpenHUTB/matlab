function onNext(this,dlg)



    if~isempty(dlg),guiMode=true;
    else,guiMode=false;
    end

    try
        if guiMode,dlg.apply;end
        hStep=getStepHandle(this);
        onNext(hStep,dlg);
        clearStatusMessage(this,dlg);
    catch ME
        this.LastErrorID=ME.identifier;
        dispErrMsg=ME.message;
        switch(ME.identifier)
        case 'HDLLink:CosimWizard:LaunchFailed'
            dispErrMsg=this.ErrMsg;
        case 'HDLLink:CosimWizard:NotOnPath'
            if guiMode,dlg.setFocus('edaHdlPath');end
        end
        if guiMode
            displayErrorMessage(this,dlg,dispErrMsg);
        else
            error(struct('identifier',this.LastErrorID,'message',dispErrMsg,'stack',ME.stack));
        end
    end

end

