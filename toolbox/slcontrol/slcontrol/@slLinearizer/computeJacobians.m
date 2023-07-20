function computeJacobians(this)







    model=this.Model;
    precompile(this);
    parammgr=this.ParamMgr;
    cmgr=slcontrollib.internal.utils.getCompilationMgr(model);
    iscompiled=isCompiled(parammgr);
    this.OutputOperatingPoints=[];

    if(this.OperatingPointType==linearize.OpTypeEnum.Snapshot)



        if isFastRestartOn(cmgr)&&iscompiled
            warning(message('Slcontrol:sllinearizer:FastRestartSnapshotCheck'));
        end



        if iscompiled
            parammgr.term();
        end

        numT=numel(this.OperatingPoints);
        nump=prod(this.ParamGridSize);
        numbsub=prod(this.BlockSubGridSize);
        varysub=(nump==1)&&(numbsub>1);
        blocksubinfo.VarySubstitutions=varysub;
        blocksubinfo.Size=numbsub;
        blocksubinfo.Index2Use=[];
        this.SnapshotBlockSubInfo=blocksubinfo;
        for ct=nump:-1:1

            pushParameters(this,ct,false);


            if~this.SnapshotBlockSubInfo.VarySubstitutions
                blocksubinfo.Size=[];
                blocksubinfo.Index2Use=ct;
                this.SnapshotBlockSubInfo=blocksubinfo;
            end


            try
                Data=snapshotRun(this);
            catch E
                cleanupWithoutClose(parammgr,...
                strcmp(get_param(model,'SimulationStatus'),'paused'),...
                this.OriginalAutoMMD);
                LocalRestoreParameters(this.Model,this.OriginalParameters);
                throwAsCaller(E);
            end








            if varysub
                for ctt=1:numel(Data)
                    storageindex=(numT*rem(ctt-1,numbsub))+floor((ctt-1)/numbsub)+1;
                    this.Jacobians{storageindex}=Data(ctt).ProcessedJacobian;
                    this.OutputOperatingPoints{storageindex}=Data(ctt).OperatingPoint;
                    this.OutputInspectorData{storageindex}=Data(ctt).InspectorData;
                    this.Advisors{storageindex}=Data(ctt).Advisor;
                end
            else
                for ctt=numel(Data):-1:1



                    storageindex=numT*(ct-1)+ctt;
                    this.Jacobians{storageindex}=Data(ctt).ProcessedJacobian;
                    this.OutputOperatingPoints{storageindex}=Data(ctt).OperatingPoint;
                    this.OutputInspectorData{storageindex}=Data(ctt).InspectorData;
                    this.Advisors{storageindex}=Data(ctt).Advisor;
                end
            end
        end

        cleanupWithoutClose(parammgr,false,this.OriginalAutoMMD);
    else

        sw=ctrlMsgUtils.SuspendWarnings('SimulinkBlocks:DescriptorStateSpace:IndexMightBeHigherThanOne',...
        'SimulinkBlocks:DescriptorStateSpace:AllowDSSInAlgLoopForLinearization');%#ok<NASGU>
        nummodels=this.NModels;
        singlecompile=this.Options.AreParamsTunable;

        if singlecompile

            if~iscompiled
                try
                    parammgr.compile('lincompile');
                    iscompiled=true;
                    linearize.linutil.checkSingleTaskingSolver(this.Model);
                catch LinearizeCompilationException
                    cleanupWithoutClose(parammgr,iscompiled,this.OriginalAutoMMD);
                    if strcmp(LinearizeCompilationException.identifier,'Simulink:Bus:SigHierPropSrcDstMismatchBusSrc')
                        ctrlMsgUtils.error('Slcontrol:linearize:ErrorCompilingModelforBusLabeling',model,model);
                    else
                        throwAsCaller(LinearizeCompilationException);
                    end
                end
            end


            singlecompile=LocalCacheParameterUsage(this);
        end


        if~singlecompile&&isFastRestartOn(cmgr)
            error(message('Slcontrol:sllinearizer:FastRestartNonTunableParams'));
        end

        if singlecompile
            assert(iscompiled);

            try
                for ct=nummodels:-1:1
                    storageindex=nummodels-ct+1;
                    try
                        pushParameters(this,ct,true);
                    catch E
                        myE=MException(message('Slcontrol:sllinearizer:ParamVaryError'));
                        myE=myE.addCause(E);
                        throw(myE);
                    end
                    if(this.OperatingPointType==linearize.OpTypeEnum.Object)

                        pushOperatingPoint(this,ct);
                    else




                    end
                    initop=LocalCreateInitialOperatingPoint(this.Model);
                    this.OutputOperatingPoints{storageindex}=initop;
                    LocalCreateJacobian(this,ct);
                end
            catch Ex

                cleanupWithoutClose(parammgr,true,this.OriginalAutoMMD);
                LocalRestoreParameters(this.Model,this.OriginalParameters);
                rethrow(Ex);
            end

            cleanupWithoutClose(parammgr,true,this.OriginalAutoMMD);
        else

            if iscompiled
                parammgr.term();
            end

            for ct=nummodels:-1:1

                pushParameters(this,ct,false);
                storageindex=nummodels-ct+1;

                try
                    parammgr.compile('lincompile');
                    if(this.OperatingPointType==linearize.OpTypeEnum.Object)

                        pushOperatingPoint(this,ct);
                    end
                    initop=LocalCreateInitialOperatingPoint(this.Model);
                    this.OutputOperatingPoints{storageindex}=initop;
                    LocalCreateJacobian(this,ct);

                    parammgr.term();
                catch LinearizeCompilationException
                    cleanupWithoutClose(parammgr,strcmp(get_param(model,'SimulationStatus'),'paused'),this.OriginalAutoMMD);
                    LocalRestoreParameters(this.Model,this.OriginalParameters);
                    throwAsCaller(LinearizeCompilationException);
                end
            end

            cleanupWithoutClose(parammgr,false,this.OriginalAutoMMD);
        end
    end
    LocalRestoreParameters(this.Model,this.OriginalParameters);


    if numel(this.OutputOperatingPoints)==prod(this.LTIFullResultSize)
        this.OutputOperatingPoints=reshape(this.OutputOperatingPoints,...
        this.LTIFullResultSize);
    end
end

function[J_preprocessed,RemovedBlockLinearizations]=LocalCreateJacobian(this,storageindex)

    BlockSubs=getBlocksToReplace(this);
    if this.StoreRemovedBlockLinearizations
        for blk_ct=1:numel(BlockSubs)
            block=BlockSubs(blk_ct).Name;
            IgnoreBlockSpecification=false;
            RemovedBlockLinearizations{blk_ct,1}=linearize.jacobian.computeBlockLin(...
            this.ParamMgr,...
            block,IgnoreBlockSpecification,this.Options,...
            BlockSubs,this.FoldFactors,storageindex);%#ok<AGROW>
        end
    else
        RemovedBlockLinearizations=[];
    end


    J_initial=linearize.jacobian.create(this.Model,linearize.createIOSpecStructure(this.IOs),this.Options.StoreOffsets||this.Options.StoreAdvisor);
    J_ordered=orderIndices(J_initial,this.ParamMgr,this.IOs,this.IOType,...
    strcmp(this.Options.UseFullBlockNameLabels,'off'),...
    strcmp(this.Options.UseBusSignalLabels,'on'));
    J_preprocessed=process(J_ordered,this.ParamMgr,linearizeOptions(this.Options),BlockSubs,this.FoldFactors,storageindex);

    this.Jacobians{storageindex}=J_preprocessed;


    checkBlockSubs(this);


    blk=[];io2inspect=[];
    if strcmp(this.IOType,'block')
        blk=this.Block2Linearize;
    elseif strcmp(this.IOType,'iopoints')
        io2inspect=this.IO2Inspect;
    end
    InspectorData=linearize.jacobian.getInspectionStructure(J_preprocessed,...
    this.Options,this.StoreJacobianData,...
    this.StoreRemovedBlockLinearizations,RemovedBlockLinearizations,...
    true,...
    this.IOType,blk,io2inspect,this.ParamMgr);
    this.OutputInspectorData{storageindex}=InspectorData;



    if isempty(this.OperatingPoints)
        op=this.OutputOperatingPoints{this.NModels-storageindex+1};
    else
        if numel(this.OperatingPoints)>1
            op=this.OperatingPoints(storageindex);
        else
            op=this.OperatingPoints(1);
        end
    end
    adv=linearize.advisor.internal.generateAdvisor(J_preprocessed,this,storageindex,op);
    this.Advisors{storageindex}=adv;
end

function LocalRestoreParameters(model,param_orig)
    for ct=1:numel(param_orig)
        sdo.setValueInModel(model,param_orig(ct).Name,...
        param_orig(ct).Value);
    end
end

function singlecompile=LocalCacheParameterUsage(this)

    singlecompile=true;

    p=this.Parameters;
    if isempty(p)
        return;
    end

    numparams=numel(p);
    model=this.Model;


    dataAccessor=Simulink.data.DataAccessor.create(model);
    varobjs=Simulink.data.VariableIdentifier.empty(numparams,0);
    for ct=1:numparams
        e=p(ct).Name;

        v=slLinearizer.getVarNameFromExpression(e);

        varobjs(ct)=dataAccessor.identifyByName(v);
    end



    assert(strcmp(get_param(model,'SimulationStatus'),'paused'));
    varusage=Simulink.findVars(model,varobjs,'SearchMethod','cached');
    this.ParameterUsage=varusage;


    singlecompile=LocalCheckTunableParams(this);
end

function tunableparams=LocalCheckTunableParams(this)
    tunableparams=true;
    params=this.Parameters;

    for ct=1:numel(this.ParameterUsage)
        ud=this.ParameterUsage(ct).DirectUsageDetails;
        for ctdd=1:numel(ud)

            if isempty(ud(ctdd).DirectUsageDetails)
                prop=ud(ctdd).Properties;
                expressions=ud(ctdd).Expressions;
                blk=ud(ctdd).Identifier;
            else
                prop=ud(ctdd).Properties;
                expressions=ud(ctdd).Expressions;
                blk=ud(ctdd).DirectUsageDetails.Identifier;


                if LocalIsVariant(blk)
                    param=this.ParameterUsage(ct).Name;
                    warning(message('Slcontrol:sllinearizer:ParamNonTunableVariant',...
                    param,blk));
                    tunableparams=false;
                    return;
                end
            end

            if strcmp(get_param(blk,'type'),'block_diagram')
                tunableparams=false;
                return
            end

            if strcmp(get_param(blk,'BlockType'),'ModelReference')
                param=this.ParameterUsage(ct).Name;

                if linearize.linutil.checkParameterizedModelArguments(blk,param)
                    continue
                end


                srctype=this.ParameterUsage(ct).SourceType;
                assert(any(ismember({'base workspace','data dictionary'},srctype)));
                paramval=Simulink.data.evalinGlobal(this.Model,param);

                if~isa(paramval,'Simulink.Parameter')||strcmp(paramval.StorageClass,'auto')
                    warning(message('Slcontrol:sllinearizer:ParamNonTunableMdlRef',...
                    param,get_param(blk,'ModelName'),blk));
                    tunableparams=false;
                    return;
                end
            end
            dlg_param=get_param(blk,'DialogParameters');
            mask_param=get_param(blk,'MaskObject');



            for ctp=1:numel(prop)
                if isempty(prop{ctp})
                    continue;
                end
                if isstruct(dlg_param)&&~isempty(fieldnames(dlg_param))&&isfield(dlg_param,(prop{ctp}))
                    attribs=dlg_param.(prop{ctp}).Attributes;

                    istunable=~any(strcmp(attribs,'read-only-if-compiled'));
                else
                    if~isempty(mask_param)&&~isempty(mask_param.Parameters)

                        names={mask_param.Parameters.Name}';

                        idx=ismember(names,prop{ctp});
                        if any(idx)

                            istunable=strcmp(mask_param.Parameters(idx).Tunable,'on');
                        else
                            tunableparams=false;
                            return;
                        end
                    else
                        tunableparams=false;
                        return;
                    end
                end

                if~istunable
                    tunableparams=LocalContainParamName(params,expressions,prop,ctp,blk);
                    if~tunableparams
                        return;
                    end
                end
            end
        end
    end
end

function val=LocalIsVariant(blk)
    val=...
    strcmp(get_param(blk,'type'),'block')&&...
    (strcmp(get_param(blk,'BlockType'),'ModelReference')||...
    strcmp(get_param(blk,'BlockType'),'SubSystem'))&&...
    strcmp(get_param(blk,'variant'),'on');
end

function strippedname=LocalStripIndexing(paramname)
    ind=regexp(paramname,'[({]');
    if isempty(ind)
        strippedname=paramname;
    else
        strippedname=paramname(1:ind(end)-1);
    end
end


function op=LocalCreateInitialOperatingPoint(model)



    opdata=opcond.internal.createOPDataInterface(model);


    ws=warning('off','SLControllib:opcond:ModelHasNonDoubleRootPortInputDataTypes');
    cln1=onCleanup(@()warning(ws));

    syncStates(opdata,true);
    syncInputs(opdata);

    op=opcond.OperatingPoint(model);

    update(op,false,opdata);
end

function tunableparams=LocalContainParamName(params,expressions,prop,counter,blk)
    tunableparams=true;

    for ctpp=1:numel(params)

        if~isempty(strfind(expressions{counter},LocalStripIndexing(params(ctpp).Name)))

            warning(message('Slcontrol:sllinearizer:ParamNonTunable',...
            ctpp,params(ctpp).Name,prop{counter},blk,...
            expressions{counter}));
            tunableparams=false;
            return;
        end
    end
end




