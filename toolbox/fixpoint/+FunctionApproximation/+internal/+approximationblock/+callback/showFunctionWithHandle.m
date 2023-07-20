function modelObject=showFunctionWithHandle(variantSystemHandle,variantTag)




    sid=Simulink.ID.getSID(variantSystemHandle);
    sidHex=fixed.internal.utility.shaHex(sid);
    finalModelName=[variantTag,'_id_',sidHex];
    if exist(finalModelName,'file')==4

        open_system(finalModelName);
        modelObject=get_param(finalModelName,'Object');
    else
        originalModel=get_param(bdroot(variantSystemHandle),'Object');
        workspace=originalModel.ModelWorkspace;
        data=workspace.data;
        modelWorkspaceVariables=cell(numel(data),2);
        for iData=1:numel(data)
            modelWorkspaceVariables{iData,1}=data(iData).Name;
            modelWorkspaceVariables{iData,2}=data(iData).Value;
        end


        adapter=FunctionApproximation.internal.approximationblock.TagToBlockAdapter();
        schema=FunctionApproximation.internal.approximationblock.BlockSchema();
        maskVariables=get_param(variantSystemHandle,'MaskWSVariables');
        listOfNames={maskVariables.Name};
        [listOfNames,indices]=setdiff(listOfNames,schema.getAllParameterNames());
        maskVariables=maskVariables(indices);

        maskWorkspaceVariables=cell(numel(listOfNames),2);
        for ii=1:numel(listOfNames)
            variableName=listOfNames{ii};
            value=maskVariables(ii).Value;
            maskWorkspaceVariables{ii,1}=variableName;
            maskWorkspaceVariables{ii,2}=value;
        end



        newSystemHandle=new_system;
        load_system(newSystemHandle);
        variantHandle=getVariantHandle(adapter,variantSystemHandle,variantTag);
        variantFullName=Simulink.ID.getFullName(variantHandle);
        Simulink.SubSystem.copyContentsToBlockDiagram(variantFullName,newSystemHandle)
        modelName=get(newSystemHandle,'Name');
        modelObject=get_param(modelName,'Object');
        w=modelObject.ModelWorkSpace;
        for iData=1:size(modelWorkspaceVariables,1)
            w.assignin(modelWorkspaceVariables{iData,1},modelWorkspaceVariables{iData,2});
        end
        for iData=1:size(maskWorkspaceVariables,1)
            w.assignin(maskWorkspaceVariables{iData,1},maskWorkspaceVariables{iData,2});
        end

        modelObject.DataDictionary=originalModel.DataDictionary;

        maskObject=Simulink.Mask.get(variantSystemHandle);
        maskParameter=maskObject.getParameter(schema.ProblemStructParameterName);
        if~isempty(maskParameter)
            problemStruct=jsondecode(maskParameter.Value);
            inputTypes=problemStruct.InputTypes;
            inputTypes=convertCharsToStrings(inputTypes);
            for ii=1:numel(inputTypes)
                datatypeContainer=parseDataType(inputTypes{ii});
                set_param([modelObject.Name,'/In',int2str(ii)],'OutDataTypeStr',datatypeContainer.ResolvedString);
            end
        end


        modelObject.Name=finalModelName;
        modelObject.Open='on';
        modelObject.Zoomfactor='fit to view';
        modelObject.Dirty='off';
    end
end


