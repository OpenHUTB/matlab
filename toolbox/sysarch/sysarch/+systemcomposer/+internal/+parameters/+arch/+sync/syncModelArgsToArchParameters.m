function syncModelArgsToArchParameters(model,arch)









    if isa(arch,'systemcomposer.architecture.model.design.Architecture')
        arch=systemcomposer.internal.getWrapperForImpl(arch);
    end


    modelName=get_param(model,'Name');
    try



        wasDirty=get_param(modelName,'dirty');
        args=slInternal('getParameterArguments',modelName);
        set_param(modelName,'dirty',wasDirty);
    catch


        set_param(modelName,'dirty',wasDirty);
        return;
    end



    if isempty(args)
        return;
    end

    wasDirty=get_param(modelName,'dirty');
    oc=onCleanup(@()set_param(modelName,'dirty',wasDirty));

    allPrmNames=string.empty;

    localArgs={};
    promotedArgs={};
    for i=1:length(args)
        anArg=args(i);
        if strcmp(modelName,anArg.ParameterCreatedFrom)
            localArgs{end+1}=anArg;%#ok<AGROW>
            allPrmNames(end+1)=anArg.ArgName;
        else
            [prmName,~]=locConvertSIDArgName(anArg);
            allPrmNames(end+1)=prmName;
            promotedArgs{end+1}=anArg;%#ok<AGROW> 
        end
    end


    for i=1:length(localArgs)
        prmName=localArgs{i}.ArgName;


        locSyncParamDefFromWksVar(arch,model,prmName,prmName);
    end


    paramNames=arch.getParameterNames;
    paramsToRemove=string.empty;


    cnt=1;
    for i=1:numel(paramNames)
        transformedName=replace(paramNames(i),{'.','/'},'_');
        if~contains(allPrmNames,transformedName)
            paramsToRemove(cnt)=paramNames(i);
            cnt=cnt+1;
        end
    end

    for prm=paramsToRemove
        arch.removeParameter(prm);
    end




    if arch.Definition~=systemcomposer.arch.ArchitectureDefinition.Behavior
        return;
    end




    for i=1:length(promotedArgs)
        anArg=promotedArgs{i};
        [prmName,isFromProtectedModel]=locConvertSIDArgName(anArg);
        if isFromProtectedModel

            systemcomposer.internal.arch.internal.getOrAddParamDef(arch,prmName);
        else


            srcModel=anArg.ParameterCreatedFrom;
            varName=anArg.DisplayName;
            locSyncPromotedParam(arch,srcModel,prmName,varName);
        end
    end
end

function[newName,isFromProtectedModel]=locConvertSIDArgName(arg)

    prmName=arg.DisplayName;
    sidPath=extractBefore(arg.SIDPath,['.',prmName]);
    parts=split(sidPath,'.');
    modelName=arg.ModelName;
    newName=prmName;
    isFromProtectedModel=false;
    for i=1:length(parts)
        block=Simulink.ID.getHandle([modelName,':',parts{i}]);
        blockName=get_param(block,'Name');
        blockParent=split(get_param(block,'Parent'),'/');
        if(numel(blockParent)>1)

            parentPath=join(blockParent(2:end),'_');
            newName=[parentPath{1},'_',blockName,'_',newName];%#ok<AGROW> 
        else
            newName=[blockName,'_',newName];%#ok<AGROW>
        end
        try
            modelName=get_param(block,'ModelName');
        catch

            isFromProtectedModel=true;
            break;
        end
    end
end


function locSyncParamDefFromWksVar(arch,model,paramName,varName)

    mdlWks=get_param(model,'ModelWorkspace');
    if mdlWks.hasVariable(varName)


        systemcomposer.internal.parameters.arch.sync.updateParameterForModelWkspChange(model,paramName,'Argument',true);
    end
end

function locSyncPromotedParam(arch,srcModel,prmName,varName)

    mdlH=load_system(srcModel);
    mdlWks=get_param(mdlH,'ModelWorkspace');
    if mdlWks.hasVariable(varName)
        var=mdlWks.getVariable(varName);


        systemcomposer.internal.parameters.arch.sync.createParameterDefFromPromotedVar(arch,prmName,var,srcModel);
    end

end


