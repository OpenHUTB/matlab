function toggleExclusiontab





    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    memenus=mdladvObj.MEmenus;
    if isfield(memenus,'ViewExclusiontab')&&isprop(memenus.ViewExclusiontab,'on')
        if strcmp(memenus.ViewExclusiontab.on,'on')
            mdladvObj.ShowExclusionTab=true;
        else
            mdladvObj.ShowExclusionTab=false;
        end
        imme=DAStudio.imExplorer(mdladvObj.MAExplorer);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyChangedEvent',selectedNode);
    end
