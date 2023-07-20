function opencsh




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.ConfigUIWindow;
    mecb=mdladvObj.CheckLibraryBrowser;
    if isa(me,'DAStudio.Explorer')
        if isa(mecb,'DAStudio.Explorer')&&mecb.hasFocus
            me=mecb;
        end
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if isa(selectedNode,'ModelAdvisor.ConfigUI')&&~isempty(selectedNode.CSHParameters)
            if isfield(selectedNode.CSHParameters,'MapKey')&&...
                isfield(selectedNode.CSHParameters,'TopicID')
                mapkey=['mapkey:',selectedNode.CSHParameters.MapKey];
                topicid=selectedNode.CSHParameters.TopicID;
                helpview(mapkey,topicid,'CSHelpWindow');
            end
        end
    end
