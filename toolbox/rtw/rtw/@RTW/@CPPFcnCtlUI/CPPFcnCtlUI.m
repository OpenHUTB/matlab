function h=CPPFcnCtlUI(fclass)




    h=RTW.CPPFcnCtlUI;
    h.fcnclass=fclass;

    if strcmp(class(fclass),'RTW.ModelCPPDefaultClass')||...
        strcmp(class(fclass),'RTW.ModelCPPVoidClass')
        h.preFunctionClass=0;
    elseif strcmp(class(fclass),'RTW.ModelCPPArgsClass')
        h.preFunctionClass=1;
    end

    h.validationStatus=1;
    h.validationResult=DAStudio.message('RTW:fcnClass:pressValidate');


    h.addBlockDiagramCallback('PreClose',@()delete(h));
