function cba_build(explorerid)






    me=DeploymentDiagram.getexplorer('ID',explorerid);
    currNode=me.imme.getCurrentTreeNode;



    if isempty(currNode)
        return;
    end

    if isa(currNode,'Simulink.DistributedTarget.SoftwareNode')&&...
        ~isempty(me.getRoot)
        mgr=me.getRoot;
        topmdl=mgr.ParentDiagram;
        currNode.ParentArchitecture.setSoftwareNodeForBuild(currNode.Name);
        rtwbuild(topmdl);
    end

end

