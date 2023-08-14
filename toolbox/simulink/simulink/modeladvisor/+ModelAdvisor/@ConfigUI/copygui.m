function copygui




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.ConfigUIWindow;
    mecb=mdladvObj.CheckLibraryBrowser;
    if isa(me,'DAStudio.Explorer')
        if isa(mecb,'DAStudio.Explorer')&&mecb.hasFocus
            me=mecb;
        end
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if~isa(selectedNode,'ModelAdvisor.ConfigUI')
            return
        end
        mdladvObj.ConfigUICopyObj=copytree(selectedNode);
        modeladvisorprivate('modeladvisorutil2','UpdatePasteMenuToolbar');
    end
