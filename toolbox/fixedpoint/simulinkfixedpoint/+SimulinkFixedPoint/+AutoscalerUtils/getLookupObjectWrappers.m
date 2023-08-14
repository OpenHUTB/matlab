function dataObjectWrappers=getLookupObjectWrappers(modelName,dataObjectClass)









    switch dataObjectClass
    case 'Simulink.LookupTable'
        wrapperCreator='LookupTableObjectWrapperCreator';

        parser=SimulinkFixedPoint.SimulinkVariableUsageParser.getParserForDataObjects();
    case 'Simulink.Breakpoint'
        wrapperCreator='BreakpointObjectWrapperCreator';

        parser=SimulinkFixedPoint.SimulinkVariableUsageParser.getParserForDataObjects();
    end




    workspaceFinder=SimulinkFixedPoint.AutoscalerUtils.WorkspaceObjectFinder(modelName,dataObjectClass);
    workspaceFinder.filterOutShadowedVars=true;


    objectsInGlobalWorkspace=workspaceFinder.getNameListFromGlobalWks;
    nGlobalObjects=numel(objectsInGlobalWorkspace);


    objectsInModelWorkspace=workspaceFinder.getNameListFromModelWks;
    nModelObjects=numel(objectsInModelWorkspace);


    dataObjectWrappers=cell(1,nGlobalObjects+nModelObjects);

    for ii=1:nGlobalObjects

        objectName=objectsInGlobalWorkspace{ii};



        if isAtLeastOneUserValid(...
            parser,...
            modelName,...
            objectName,...
            'SearchMethod','cached')
            sourceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.Base;
            object=slResolve(objectName,workspaceFinder.modelName);
            dataObjectWrappers{ii}=SimulinkFixedPoint.(wrapperCreator).getWrapper(...
            object,objectName,modelName,sourceType);
        end
    end

    for ii=1:nModelObjects

        objectName=objectsInModelWorkspace{ii};



        if isAtLeastOneUserValid(...
            parser,...
            modelName,...
            objectName,...
            'SearchMethod','cached')

            sourceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.Model;
            object=slprivate('modelWorkspaceGetVariableHelper',workspaceFinder.hModelWks,objectName);
            dataObjectWrappers{nGlobalObjects+ii}=SimulinkFixedPoint.(wrapperCreator).getWrapper(...
            object,objectName,modelName,sourceType);
        end
    end


    emptyIndices=false(numel(dataObjectWrappers),1);
    for ii=1:numel(dataObjectWrappers)
        if isempty(dataObjectWrappers{ii})
            emptyIndices(ii)=true;
        end
    end
    dataObjectWrappers(emptyIndices)=[];
end


