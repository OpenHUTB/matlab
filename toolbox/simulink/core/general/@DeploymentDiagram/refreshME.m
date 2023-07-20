function refreshME(varargin)









    sourceObj=varargin{1};

    modelName=sourceObj.ParentDiagram;
    event=varargin{2};

    if nargin>2
        explorer=DeploymentDiagram.getexplorer('ID',varargin{3});
    else
        explorer=DeploymentDiagram.getexplorer('name',modelName);
    end





    if isempty(explorer)
        return;
    end



    if strcmp(event.EventName,'MappingsBeingDestroyed')
        DeploymentDiagram.deleteTEAndChildren(explorer);
        return;
    end



    switch event.EventName
    case{'ComponentMapChanged','MappingEntityDeleted',...
        'MappingEntityAdded'}
        assert(isa(sourceObj,'Simulink.DistributedTarget.Mapping'));
        mapping=explorer.findNodes('Mapping');
        DeploymentDiagram.fireHierarchyChange(mapping);
        sNode=explorer.findNodes('SoftwareNode');
        DeploymentDiagram.fireHierarchyChange(sNode);

    otherwise
        assert(false,'Unhandled event in cbe_update');
    end



    selectedListNode=explorer.imme.getSelectedListNodes;
    if~isempty(selectedListNode)
        DeploymentDiagram.firePropertyChange(selectedListNode);
    end



