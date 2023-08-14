


function ivListSource=getInternalVarListSource(modelName)




    ivListType={};
    ivListEnum={};
    iTree=[];
    scalarIdx={};
    scalarVariableList=[];

    compiledPortAttribs_sig={};
    compiledPortAttribs_tp={};
    compiledPortAttribs_ds={};
    varNames_sig={};
    varNames_tp={};
    varNames_ds={};
    sig_blks={};
    tp_blks={};
    ds_blks={};


    feval(modelName,[],[],[],'compile');
    oc=onCleanup(@()feval(modelName,[],[],[],'term'));

    root_blks=find_system(modelName,'SearchDepth',1,'MatchFilter',@Simulink.match.activeVariants);
    for i=2:length(root_blks)
        blkType=get_param(root_blks{i},'BlockType');

        if strcmp(blkType,'Inport')||strcmp(blkType,'Outport')
            continue;
        end
        ph=get_param(root_blks{i},'PortHandles');

        if strcmp(blkType,'DataStoreRead')
            ds_name=get_param(root_blks{i},'DataStoreName');

            oph=ph.Outport;
            compiledPortAttrib.dt=get_param(oph,'CompiledPortDataType');
            compiledPortAttrib.dim=resolveDimensions(get_param(oph,'CompiledPortDimensions'));
            if~any(strcmp(varNames_ds,ds_name))

                compiledPortAttribs_ds=[compiledPortAttribs_ds,compiledPortAttrib];
                [varNames_ds,ds_blks]=addDataStore(ds_name,root_blks{i},varNames_ds,ds_blks);
            end
        elseif strcmp(blkType,'DataStoreWrite')
            ds_name=get_param(root_blks{i},'DataStoreName');

            iph=ph.Inport;
            compiledPortAttrib.dt=get_param(iph,'CompiledPortDataType');
            compiledPortAttrib.dim=resolveDimensions(get_param(iph,'CompiledPortDimensions'));
            if~any(strcmp(varNames_ds,ds_name))

                compiledPortAttribs_ds=[compiledPortAttribs_ds,compiledPortAttrib];
                [varNames_ds,ds_blks]=addDataStore(ds_name,root_blks{i},varNames_ds,ds_blks);
            end
        elseif~strcmp(blkType,'SubSystem')


            oph=ph.Outport;
            for j=1:length(oph)


                isLogging=get_param(oph(j),'DataLogging');
                isTP=get_param(oph(j),'TestPoint');

                compiledPortAttrib.dt=get_param(oph(j),'CompiledPortDataType');
                compiledPortAttrib.dim=resolveDimensions(get_param(oph(j),'CompiledPortDimensions'));

                l=get_param(oph(1),'line');
                if l==-1

                    continue;
                else
                    dst_blk=get_param(l,'DstBlockHandle');
                    if dst_blk==-1


                        isRootOutport=false;
                    else
                        isRootOutport=strcmp(get_param(dst_blk,'BlockType'),'Outport');
                    end
                    if strcmp(isLogging,'on')
                        if~isRootOutport
                            compiledPortAttribs_sig=[compiledPortAttribs_sig,compiledPortAttrib];
                            [varNames_sig,sig_blks]=addLoggedSignal(oph(j),root_blks{i},j,varNames_sig,sig_blks,compiledPortAttrib);
                        end
                    elseif strcmp(isTP,'on')
                        compiledPortAttribs_tp=[compiledPortAttribs_tp,compiledPortAttrib];
                        [varNames_tp,tp_blks]=addTestPoint(oph(j),root_blks{i},j,varNames_tp,tp_blks,compiledPortAttrib);
                    end
                end
            end
        else
            oph=ph.Outport;

            for j=1:length(oph)

                isTP=get_param(oph(j),'TestPoint');

                compiledPortAttrib.dt=get_param(oph(j),'CompiledPortDataType');
                compiledPortAttrib.dim=resolveDimensions(get_param(oph(j),'CompiledPortDimensions'));
                if strcmp(isTP,'on')
                    compiledPortAttribs_tp=[compiledPortAttribs_tp,compiledPortAttrib];
                    [varNames_tp,tp_blks]=addTestPoint(oph(j),root_blks{i},j,varNames_tp,tp_blks,compiledPortAttrib);
                end
            end

            ss_blks=find_system(root_blks{i},'MatchFilter',@Simulink.match.activeVariants);
            for j=2:length(ss_blks)
                ss_ph=get_param(ss_blks{j},'PortHandles');
                ss_oph=ss_ph.Outport;
                for k=1:length(ss_oph)
                    ss_isLogging=get_param(ss_oph(k),'DataLogging');
                    ss_isTP=get_param(ss_oph(k),'TestPoint');

                    ss_compiledPortAttrib.dt=get_param(ss_oph(k),'CompiledPortDataType');
                    ss_compiledPortAttrib.dim=resolveDimensions(get_param(ss_oph(k),'CompiledPortDimensions'));
                    if strcmp(ss_isLogging,'on')
                        compiledPortAttribs_sig=[compiledPortAttribs_sig,ss_compiledPortAttrib];
                        [varNames_sig,sig_blks]=addLoggedSignal(ss_oph(k),ss_blks{j},k,varNames_sig,sig_blks,ss_compiledPortAttrib);
                    elseif strcmp(ss_isTP,'on')
                        compiledPortAttribs_tp=[compiledPortAttribs_tp,ss_compiledPortAttrib];
                        [varNames_tp,tp_blks]=addTestPoint(ss_oph(k),ss_blks{j},k,varNames_tp,tp_blks,ss_compiledPortAttrib);
                    end
                end
            end
        end
    end
    clear oc;


    [ivListType,ivListEnum,iTree,scalarIdx,scalarVariableList]=addVarToList(varNames_sig,'Logged Signal',iTree,scalarVariableList,scalarIdx,ivListType,ivListEnum,modelName,sig_blks,compiledPortAttribs_sig);


    [ivListType,ivListEnum,iTree,scalarIdx,scalarVariableList]=addVarToList(varNames_tp,'Test Point',iTree,scalarVariableList,scalarIdx,ivListType,ivListEnum,modelName,tp_blks,compiledPortAttribs_tp);


    [ivListType,ivListEnum,iTree,scalarIdx,scalarVariableList]=addVarToList(varNames_ds,'Data Store',iTree,scalarVariableList,scalarIdx,ivListType,ivListEnum,modelName,ds_blks,compiledPortAttribs_ds);

    ivListSource=internal.internalVarConfig.spreadSheetSource(...
    ivListType,...
    ivListEnum,...
    iTree,...
    scalarIdx,...
    scalarVariableList,...
    modelName);
end

function[varNames_sig,sig_blks]=addLoggedSignal(h,blk,port,varNames_sig,sig_blks,compiledPortAttrib)

    if strcmp(get_param(h,'DataLoggingNameMode'),'Custom')

        sigName=get_param(h,'DataLoggingName');
    else

        sigName=get_param(h,'Name');
    end
    if~isempty(sigName)

        varNames_sig=[varNames_sig,sigName];
        blk=[blk,':',num2str(port)];
        sig_blks=[sig_blks,blk];
    end
end

function[varNames_tp,tp_blks]=addTestPoint(h,blk,port,varNames_tp,tp_blks,compiledPortAttrib)

    tpName=get_param(h,'Name');
    if~isempty(tpName)

        varNames_tp=[varNames_tp,tpName];
        blk=[blk,':',num2str(port)];
        tp_blks=[tp_blks,blk];
    end
end

function[varNames_ds,ds_blks]=addDataStore(ds_name,blk,varNames_ds,ds_blks)
    varNames_ds=[varNames_ds,ds_name];
    ds_blks=[ds_blks,blk];
end

function dim=resolveDimensions(dims)


    if dims(1)==-2

        numLeaf=dims(2);
        idx=3;
        for i=1:numLeaf
            n=dims(idx);
            dim{i}=dims(idx+1:idx+n);
            idx=idx+n+1;
        end

    elseif length(dims)==2

        dim=dims;
    else
        dim=dims(2:end);
    end
end

function[ivListType,ivListEnum,iTree,scalarIdx,scalarVariableList]=addVarToList(varNames,sourceType,iTree,scalarVariableList,scalarIdx,ivListType,ivListEnum,modelName,blkPath,compiledPortAttribs)
    for i=1:length(varNames)
        idxBegin=length(scalarVariableList)+1;
        [iTree,scalarVariableList]=FMU2ExpCSDialog.addInternalVarToList(modelName,iTree,scalarVariableList,sourceType,blkPath{i},varNames{i},compiledPortAttribs{i});
        idxEnd=length(scalarVariableList);
        if idxBegin<=idxEnd
            ivListType=[ivListType,{'edit'}];
            ivListEnum=[ivListEnum,{''}];
            scalarIdx=[scalarIdx,idxBegin:idxEnd];
        end
    end
end
