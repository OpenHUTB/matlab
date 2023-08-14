function refactorParameter(dependency,paramName,newPath)




    block=dependency.UpstreamComponent.Path;
    oldParam=get_param(block,paramName);
    oldPath=dependency.DownstreamNode.Location{1};
    import dependencies.internal.action.refactor.createRefactoredFileParameter;
    newParam=createRefactoredFileParameter(oldParam,oldPath,newPath);
    set_param(block,paramName,newParam);
end
