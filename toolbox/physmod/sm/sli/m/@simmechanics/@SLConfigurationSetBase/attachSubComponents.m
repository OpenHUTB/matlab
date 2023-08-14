function attachSubComponents(thisConfigSet)



    configTree=simmechanics.sli.internal.getConfigParamTree();
    csBldVis=simmechanics.sli.internal.ConfigSetBuildVisitor(thisConfigSet);
    csBldVis.getConfigSet(configTree);
