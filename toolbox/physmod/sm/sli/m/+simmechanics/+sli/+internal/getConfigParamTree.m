function cftree=getConfigParamTree()





    persistent configTree

    if isempty(configTree)
        simpleNodeBldr=pm.util.SimpleNodeBuilder(...
        @simmechanics.sli.internal.csgroup_node_builder);
        compNodeBldr=pm.util.CompoundNodeBuilder(...
        @simmechanics.sli.internal.cstree_node_builder);
        dirTreeBldr=pm.util.DirTreeBuilder(compNodeBldr,simpleNodeBldr);
        configDir=fullfile(matlabroot,'toolbox','physmod','sm','sli',...
        'm','+simmechanics','+sli','+configparams');
        configTree=dirTreeBldr.buildTree(configDir);
    end

    cftree=configTree;

    mlock;
