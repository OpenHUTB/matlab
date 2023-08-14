function cba_convertAutoTaskToReal(varargin)




    explorerid=varargin{1};
    flag='';
    if nargin>1
        flag=varargin{2};
    end

    me=DeploymentDiagram.getexplorer('ID',num2str(explorerid));
    if isempty(me)
        return;
    end
    currTreeNode=me.imme.getCurrentTreeNode;
    currListNode=me.imme.getSelectedListNodes;
    if isempty(flag)
        if~(isa(currTreeNode,'Simulink.DistributedTarget.Mapping')&&...
            isa(currListNode,'Simulink.SoftwareTarget.BlockToTaskMapping_Explorer'))
            return;
        end

        currListNode.createTaskAndMapThisOne();

    else
        assert(any(strcmp(flag,{'trigger','task'})));
        assert(isa(currTreeNode,'Simulink.SoftwareTarget.AutogenTask')||...
        isa(currTreeNode,'Simulink.SoftwareTarget.AutogenTrigger'));
        currTreeNode.convertToGraphical;
    end

    mapping=me.findNodes('Mapping');
    DeploymentDiagram.fireHierarchyChange(mapping);