function copyParametersBetweenModels(srcModel,tgtArchitecture)




    if isa(tgtArchitecture,'systemcomposer.architecture.model.design.Architecture')
        tgtArchitecture=systemcomposer.internal.getWrapperForImpl(tgtArchitecture);
    end


    srcModelName=get_param(srcModel,'Name');
    try



        wasDirty=get_param(srcModelName,'dirty');
        args=slInternal('getParameterArguments',srcModelName);
        set_param(srcModelName,'dirty',wasDirty);
    catch


        set_param(srcModelName,'dirty',wasDirty);
        return;
    end


    if isempty(args)
        return;
    end


    localArgs={};
    promotedArgs={};
    for i=1:length(args)
        anArg=args(i);
        if strcmp(srcModelName,anArg.ParameterCreatedFrom)
            localArgs{end+1}=anArg;%#ok<AGROW> 
        else
            promotedArgs{end+1}=anArg;%#ok<AGROW> 
        end
    end


    for i=1:length(localArgs)
        prmName=localArgs{i}.ArgName;


        locCopyMdlArgsFromWksVar(tgtArchitecture,srcModelName,prmName,prmName);
    end




    if tgtArchitecture.Definition~=systemcomposer.arch.ArchitectureDefinition.Behavior
        return;
    end




    for i=1:length(promotedArgs)
        anArg=promotedArgs{i};
        [prmName,isFromProtectedModel]=locConvertSIDArgName(anArg);
        if isFromProtectedModel

            systemcomposer.internal.arch.internal.getOrAddParamDef(tgtArchitecture,prmName);
        else


            srcModel=anArg.ParameterCreatedFrom;
            varName=anArg.DisplayName;
            locPromoteParameter(tgtArchitecture,srcModel,prmName,varName);
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


function locCopyMdlArgsFromWksVar(tgtArch,srcModel,~,varName)

    mdlWks=get_param(srcModel,'ModelWorkspace');
    tgtMdlWks=get_param(tgtArch.Name,'ModelWorkspace');
    if mdlWks.hasVariable(varName)
        var=mdlWks.getVariable(varName);
        assignin(tgtMdlWks,varName,var);
        if~isobject(var)
            existing_args=get_param(tgtArch.Name,'ParameterArgumentNames');
            if isempty(existing_args)
                existing_args=varName;
            else
                existing_args=sprintf('%s, %s',existing_args,varName);
            end
            set_param(tgtArch.Name,'ParameterArgumentNames',existing_args);
        end
        systemcomposer.internal.arch.internal.processBatchedPluginEvents(tgtArch.SimulinkModelHandle);
    end
end

function locPromoteParameter(tgtArchitecture,~,prmName,varName)
    idx=strfind(prmName,'_');
    promotedFromRaw=prmName(1:idx(end)-1);
    promotedPath=strrep(promotedFromRaw,'_','/');
    promotedFullPath=[tgtArchitecture.Name,'/',promotedPath];
    if tgtArchitecture.Definition==systemcomposer.arch.ArchitectureDefinition.Composition


        try
            bh=get_param(promotedFullPath,'handle');
            systemcomposer.internal.arch.internal.updateInstanceParamsInSL(bh,{varName},'Argument',true);
        catch

        end
    end

end


