function result=getCheckTree(this)
    root=this.maObj.TaskAdvisorRoot;
    rootID=this.maObj.TaskAdvisorRoot.ID;
    if strcmp(rootID,'SysRoot')
        rootID='_SYSTEM';
    end
    result=[];
    tree=struct('id',root.ID,...
    'state',root.State,...
    'parent',NaN,...
    'isFolder',true,...
    'iconUri',['/',root.getDisplayIcon],...
    'label',root.DisplayName,...
    'check',root.Selected,...
    'enabled',true);

    tree=gatherNodeInfo(root,rootID,tree);
    if strcmpi(tree(1).id,'SysRoot')
        tree(1).id='_SYSTEM';
        tree(1).iconUri='/toolbox/simulink/simulink/modeladvisor/resources/ma.png';
        tree(1).label='Model Advisor';
    end
    result.tree=tree;
    result.hasSavedReport=this.maObj.hasLoadedExistingData&&Simulink.ModelAdvisor.reportExists(this.maObj.SystemName);
end

function nodeInfo=gatherNodeInfo(startNode,rootID,nodeInfo)

    children=startNode.getChildren();
    for i=1:numel(children)
        if any(strcmp(children(i).getParent.ID,{'SysRoot',rootID}))||strcmp(rootID,'CommandLineRun')
            parent=rootID;
        else
            parent=children(i).getParent.ID;
        end

        nodeInfo(end+1)=struct('id',children(i).ID,...
        'state',string(children(i).State),...
        'iconUri',['/',children(i).getDisplayIcon],...
        'parent',parent,...
        'label',children(i).DisplayName,...
        'isFolder',~isa(children(i),'ModelAdvisor.Task'),...
        'check',children(i).Selected,...
        'enabled',children(i).Enable);%#ok<AGROW>
        if~isempty(children(i).getChildren())
            nodeInfo=gatherNodeInfo(children(i),rootID,nodeInfo);
        end
    end
end