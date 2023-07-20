function fcnDependencyObjs=getReferencedMFiles(system,fcnBlocks)












    fileReferences=Advisor.Utils.Simulink.getReferencedMatlabFiles(system);
    fcnDependencyObjs=[num2cell(fileReferences);fcnBlocks];

end
