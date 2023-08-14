function pvArgs=getVariableGroupsPVArgs(modelHandle)






    pvArgs={};%#ok<NASGU>

    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    varGrpsDDGComp=vmStudioHandle.getComponent('GLUE2:DDG Component',message('Simulink:VariantManagerUI:VariableGroupsTabTitle').getString());

    pvArgs=getVariableGroupsCommand(varGrpsDDGComp.getSource().VarGrpNamesSSSrc);

end
