function[out,idxInTC]=findNodes(varargin)




    taskEditor=varargin{1};
    Type=varargin{2};
    flag='';
    if nargin>2
        flag=varargin{3};
    end
    mappingMgrNode=taskEditor.getRoot;
    assert(~isempty(mappingMgrNode));
    children=mappingMgrNode.getHierarchicalChildren;


    switch Type

    case 'Architecture'
        nodeClass='Simulink.DistributedTarget.Architecture';
        parentNode=findNodes(taskEditor,'Mapping');
        assert(~isempty(parentNode));
        children=parentNode.getHierarchicalChildren;

    case 'HardwareNode'
        nodeClass='Simulink.DistributedTarget.HardwareNode';
        parentNode=findNodes(taskEditor,'Mapping');
        assert(~isempty(parentNode));
        children=parentNode.getHierarchicalChildren;

    case 'SoftwareNode'
        nodeClass='Simulink.DistributedTarget.SoftwareNode';
        parentNode=findNodes(taskEditor,'Mapping');
        assert(~isempty(parentNode));
        children=parentNode.getHierarchicalChildren;

    case 'TaskConfiguration'
        nodeClass='Simulink.SoftwareTarget.TaskConfiguration';
        parentNode=findNodes(taskEditor,'SoftwareNode');
        assert(~isempty(parentNode));
        children=[];
        for i=1:length(parentNode)
            children=[children(:);parentNode(i).getHierarchicalChildren];
        end
    case 'Periodic'
        nodeClass='Simulink.SoftwareTarget.PeriodicTrigger';
        parentNode=findNodes(taskEditor,'SoftwareNode');
        assert(~isempty(parentNode));
        children=[];
        for i=1:length(parentNode)
            children=[children(:);parentNode(i).getHierarchicalChildren];
        end
    case 'Aperiodic'
        nodeClass='Simulink.SoftwareTarget.AperiodicTrigger';
        parentNode=findNodes(taskEditor,'SoftwareNode');
        assert(~isempty(parentNode));
        children=[];
        for i=1:length(parentNode)
            children=[children(:);parentNode(i).getHierarchicalChildren];
        end
    case 'Mapping'
        nodeClass='Simulink.DistributedTarget.Mapping';
    case 'ConfigSet'
        nodeClass='Simulink.SoftwareTarget.ConfigSet';
    case 'TaskTransition'
        nodeClass='Simulink.GlobalDataTransfer';
    case 'Maps'
        nodeClass='Simulink.SoftwareTarget.BlockToTaskMapping_Explorer';
        parentNode=findNodes(taskEditor,'Mapping');
        assert(~isempty(parentNode));
        children=parentNode.getChildren;

    case 'PeriodicTasks'
        nodeClass='Simulink.SoftwareTarget.Task';
        parentNode=findNodes(taskEditor,'Periodic');
        assert(~isempty(parentNode));
        children=[];
        for i=1:length(parentNode)
            c=parentNode(i).getHierarchicalChildren;
            children=[children(:);c(:)];
        end

    case 'ProfileReport'
        nodeClass='Simulink.SoftwareTarget.ProfileReport';
        parentNode=findNodes(taskEditor,'Mapping');
        assert(~isempty(parentNode));
        children=parentNode.getHierarchicalChildren;

    case 'SystemTaskNode'
        nodeClass='Simulink.SoftwareTarget.AutogenInfo';
        parentNode=findNodes(taskEditor,'Mapping');
        assert(~isempty(parentNode));
        children=parentNode.getHierarchicalChildren;

    case 'SystemTasks'
        nodeClass='Simulink.SoftwareTarget.AutogenBaseTask';
        parentNode=findNodes(taskEditor,'SystemTaskNode');
        assert(~isempty(parentNode));
        children=parentNode.getHierarchicalChildren;

    otherwise
        assert(false,'enter a valid node Type');
    end
    numNodes=1;
    idxInTC=[];
    for i=1:length(children)
        if isa(children(i),'DAStudio.DAObjectProxy')
            child=children(i).getMCOSObjectReference;
        else
            child=children(i);
        end
        if(isa(child,nodeClass))
            if(isempty(idxInTC))

                idxInTC=i;
            end
            nodes(numNodes)=child;%#ok
            numNodes=numNodes+1;
        end;
    end


    if(numNodes==1)
        nodes=[];
    end

    out=nodes;



