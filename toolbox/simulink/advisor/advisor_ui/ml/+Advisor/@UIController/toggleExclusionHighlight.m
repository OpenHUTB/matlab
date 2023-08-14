function result=toggleExclusionHighlight(this,state)
    result=true;
    if isempty(this.maObj)
        return;
    end

    this.maObj.ShowExclusionsOnGUI=strcmp(state,'true');
    setpref('modeladvisor','ShowExclusionsOnGUI',this.maObj.ShowExclusionsOnGUI);
    me=this.maObj.MAExplorer;
    if isa(me,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        selectedNode.updateResultGUI;
    end
end