function h=FcnCtlUI(fclass,dialogHndl)




    h=RTW.FcnCtlUI;
    h.fcnclass=fclass;
    h.dialogHndl=dialogHndl;

    if strcmp(class(fclass),'RTW.FcnDefault')
        h.preFunctionClass=0;
    elseif strcmp(class(fclass),'RTW.ModelSpecificCPrototype')
        h.preFunctionClass=1;
    end

    h.validationStatus=1;
    h.validationResult=DAStudio.message('RTW:fcnClass:pressValidate');


    h.addBlockDiagramCallback('PreClose',@()delete(h));


