function FunctionClassChanged(hObj,val,hDlg)




    if val==hObj.preFunctionClass
        return;
    end

    hObj.preFunctionClass=val;

    if val==0
        if~isempty(hObj.fcnclass.cache)
            hObj.cachedFcnClass=hObj.fcnclass.cache;
        end

        newFcnClass=RTW.ModelCPPDefaultClass('',hObj.fcnclass.ModelHandle);

        newFcnClass.ViewWidget=hObj.fcnclass.ViewWidget;
        if hObj.fcnclass.RightClickBuild
            newFcnClass.RightClickBuild=true;
            newFcnClass.SubsysBlockHdl=hObj.fcnclass.SubsysBlockHdl;
        end

    elseif val==1
        hModel=hObj.fcnclass.ModelHandle;
        isExportFcnDiagram=...
        strcmp(get_param(hModel,'SolverType'),'Fixed-step')&&...
        slprivate('getIsExportFcnModel',hModel);

        if isExportFcnDiagram
            hDlg.restoreFromSchema;
            errordlg(DAStudio.message('RTW:fcnClass:ioArgsExportFunctionModel'));
        end
        if isempty(hObj.cachedFcnClass)
            newFcnClass=RTW.ModelCPPArgsClass('',hObj.fcnclass.ModelHandle);
            newFcnClass.ViewWidget=hObj.fcnclass.ViewWidget;
        else
            newFcnClass=RTW.ModelCPPArgsClass('',hObj.fcnclass.ModelHandle);
            newFcnClass.FunctionName=hObj.cachedFcnClass.FunctionName;
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

