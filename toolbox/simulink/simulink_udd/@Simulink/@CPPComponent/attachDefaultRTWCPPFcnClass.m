function attachDefaultRTWCPPFcnClass(hObj)








    hConfigSet=hObj.getConfigSet();
    if~isempty(hConfigSet)&&ishandle(hConfigSet)&&hConfigSet.isActive()
        hModel=hObj.getModel();
        if~Simulink.CodeMapping.isAutosarAdaptiveSTF(hModel)


            return;
        end
        hControlObj=get_param(hModel,'RTWCPPFcnClass');

        if get_param(hConfigSet,'IsERTTarget')=="on"&&...
            ~isa(hControlObj,'RTW.ModelCPPClass')
            dirtyFlag=get_param(hModel,'Dirty');
            cleanupObj=onCleanup(@()set_param(hModel,'Dirty',dirtyFlag));
            hControlObj=RTW.ModelCPPDefaultClass;
            hControlObj.attachToModel(hModel);
            hControlObj.getDefaultConf();
        end
    end


