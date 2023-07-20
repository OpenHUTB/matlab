
function paramListSource=getParamListSource(modelName)





    pListType={};
    pListEnum={};
    pTree=[];
    scalarIdx={};
    scalarVariableList=[];

    inports=find_system(modelName,'SearchDepth',1,'BlockType','Inport');
    outports=find_system(modelName,'SearchDepth',1,'BlockType','Outport');
    busSelectors=find_system(modelName,'SearchDepth',1,'BlockType','BusSelector');
    busCreators=find_system(modelName,'SearchDepth',1,'BlockType','BusCreator');


    modelBlk=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on','BlockType','ModelReference');

    vars_baseWkspc=Simulink.findVars(modelName,'SourceType','base workspace');
    varNames_baseWkspc={};
    for k=1:length(vars_baseWkspc)
        users=vars_baseWkspc(k).Users;
        used_in=intersect(users,inports);
        used_out=intersect(users,outports);
        used_bs=intersect(users,busSelectors);
        used_bc=intersect(users,busCreators);

        if(length(used_in)+length(used_out)+length(used_bs)+length(used_bc))<length(users)
            varNames_baseWkspc=[varNames_baseWkspc,vars_baseWkspc(k).Name];
        end
    end

    for i=1:length(varNames_baseWkspc)
        idxBegin=length(scalarVariableList)+1;
        [pTree,scalarVariableList]=FMU2ExpCSDialog.addVariableToList(modelName,pTree,scalarVariableList,'base workspace',varNames_baseWkspc{i});
        idxEnd=length(scalarVariableList);
        if idxBegin<=idxEnd
            pListType=[pListType,{'edit'}];
            pListEnum=[pListEnum,{''}];
            scalarIdx=[scalarIdx,idxBegin:idxEnd];
        end
    end

    vars_mdlWkspc=Simulink.findVars(modelName,'SourceType','model workspace','findUsedVars',true);
    varNames_mdlWkspc={};
    for k=1:length(vars_mdlWkspc)
        users=vars_mdlWkspc(k).Users;
        used_in=intersect(users,inports);
        used_out=intersect(users,outports);
        used_bs=intersect(users,busSelectors);
        used_bc=intersect(users,busCreators);

        if(length(used_in)+length(used_out)+length(used_bs)+length(used_bc))<length(users)
            varNames_mdlWkspc=[varNames_mdlWkspc,vars_mdlWkspc(k).Name];
        end
    end
    modelArguments=strsplit(get_param(modelName,'ParameterArgumentNames'),',');
    varNames_argument=intersect(varNames_mdlWkspc,modelArguments);

    for i=1:length(varNames_argument)
        idxBegin=length(scalarVariableList)+1;
        [pTree,scalarVariableList]=FMU2ExpCSDialog.addVariableToList(modelName,pTree,scalarVariableList,'model argument',varNames_argument{i});
        idxEnd=length(scalarVariableList);
        if idxBegin<=idxEnd
            pListType=[pListType,{'edit'}];
            pListEnum=[pListEnum,{''}];
            scalarIdx=[scalarIdx,idxBegin:idxEnd];
        end
    end


    for i=1:length(modelBlk)






















        info=get_param(modelBlk{i},'ParameterArgumentInfo');
        for k=1:length(info)
            if info(k).PromoteToAllAncestors

                origMdl=info(k).ParameterCreatedFrom;
                blockPath=modelBlk{i};
                if~isempty(info(k).FullPath)
                    for l=1:info(k).FullPath.getLength
                        blockPath=[blockPath,':',info(k).FullPath.getBlock(l)];
                    end
                end
                idxBegin=length(scalarVariableList)+1;













                [pTree,scalarVariableList]=FMU2ExpCSDialog.addVariableToList(origMdl,pTree,scalarVariableList,['InstArg_',blockPath],info(k).DisplayName);
                idxEnd=length(scalarVariableList);
                if idxBegin<=idxEnd


                    pListType=[pListType,{'edit'}];
                    pListEnum=[pListEnum,{''}];


                    scalarIdx=[scalarIdx,idxBegin:idxEnd];
                end
            end
        end
    end

    vars_sldd=Simulink.findVars(modelName,'SourceType','data dictionary');
    varNames_sldd={};
    for k=1:length(vars_sldd)
        users=vars_sldd(k).Users;
        used_in=intersect(users,inports);
        used_out=intersect(users,outports);
        used_bs=intersect(users,busSelectors);
        used_bc=intersect(users,busCreators);

        if(length(used_in)+length(used_out)+length(used_bs)+length(used_bc))<length(users)
            varNames_sldd=[varNames_sldd,vars_sldd(k).Name];
        end
    end


    for i=1:length(varNames_sldd)
        idxBegin=length(scalarVariableList)+1;
        [pTree,scalarVariableList]=FMU2ExpCSDialog.addVariableToList(modelName,pTree,scalarVariableList,'data dictionary',varNames_sldd{i});
        idxEnd=length(scalarVariableList);
        if idxBegin<=idxEnd
            pListType=[pListType,{'edit'}];
            pListEnum=[pListEnum,{''}];
            scalarIdx=[scalarIdx,idxBegin:idxEnd];
        end
    end

    paramListSource=internal.parameterConfig.spreadSheetSource(...
    pListType,...
    pListEnum,...
    pTree,...
    scalarIdx,...
    scalarVariableList,...
    modelName);
end