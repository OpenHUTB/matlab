function preConfig(hSrc,hDlg)





    if~isempty(hSrc.cache)
        thisMdl=hSrc.cache.ModelHandle;
    else
        thisMdl=hSrc.ModelHandle;
    end

    cs=getActiveConfigSet(thisMdl);
    commitBuild=slprivate('checkSimPrm',cs);
    if(~commitBuild)
        return;
    end

    if isempty(hSrc.cache)
        hSrc.cache=RTW.ModelSpecificCPrototype;
        hSrc.cache.Name=hSrc.Name;
        hSrc.cache.FunctionName=hSrc.FunctionName;
        hSrc.cache.InitFunctionName=hSrc.InitFunctionName;
        hSrc.cache.ModelHandle=hSrc.ModelHandle;
        hSrc.cache.selRow=0;
        hSrc.cache.RightClickBuild=hSrc.RightClickBuild;
        hSrc.cache.SubsysBlockHdl=hSrc.SubsysBlockHdl;
    end

    if hSrc.RightClickBuild
        msg=coder.internal.configFcnProtoSSBuild(hSrc.cache.SubsysBlockHdl,...
        [],'Update',hSrc.cache);
        if~isempty(msg)
            return;
        end
    end

    hSrc.cache.getDefaultConf();

    if~isempty(hSrc.ViewWidget)&&...
        ishandle(hSrc.ViewWidget)&&...
        isa(hSrc.ViewWidget,'DAStudio.Dialog')
        hSrc.ViewWidget.setWidgetValue('PrototypeFuncName',...
        hSrc.cache.FunctionName);
        hSrc.ViewWidget.setWidgetValue('PrototypeInitFuncName',...
        hSrc.cache.InitFunctionName);
    end

    hSrc.PreConfigFlag=true;

    hDlg.enableApplyButton(1);
    hDlg.refresh;



