function FunctionClassChanged(hObj,val,hDlg)




    if val==hObj.preFunctionClass
        return;
    end

    hObj.preFunctionClass=val;

    switch val
    case 0
        if~isempty(hObj.fcnclass.cache)
            hObj.cachedFcnClass=hObj.fcnclass.cache;
        end

        newFcnClass=RTW.FcnDefault('',hObj.fcnclass.ModelHandle);
        newFcnClass.ViewWidget=hObj.fcnclass.ViewWidget;
        if hObj.fcnclass.RightClickBuild
            newFcnClass.RightClickBuild=true;
            newFcnClass.SubsysBlockHdl=hObj.fcnclass.SubsysBlockHdl;
        end

    case 1
        if isempty(hObj.cachedFcnClass)||...
            ~isa(hObj.cachedFcnClass,'RTW.ModelSpecificCPrototype')
            newFcnClass=RTW.ModelSpecificCPrototype('',hObj.fcnclass.ModelHandle);
            newFcnClass.ViewWidget=hObj.fcnclass.ViewWidget;
        else
            newFcnClass=RTW.ModelSpecificCPrototype('',hObj.fcnclass.ModelHandle);
            newFcnClass.FunctionName=hObj.cachedFcnClass.FunctionName;
            newFcnClass.InitFunctionName=hObj.cachedFcnClass.InitFunctionName;
            newFcnClass.Data=hObj.cachedFcnClass.Data;
        end

        if hObj.fcnclass.RightClickBuild
            newFcnClass.RightClickBuild=true;
            newFcnClass.SubsysBlockHdl=hObj.fcnclass.SubsysBlockHdl;
        end
    end


    newFcnClass.ViewWidget=hObj.fcnclass.ViewWidget;
    hObj.fcnclass=newFcnClass;

    hObj.validationResult=DAStudio.message('RTW:fcnClass:pressValidate');
    hObj.validationStatus=true;
    hDlg.resetSize(true);
    hDlg.refresh();

