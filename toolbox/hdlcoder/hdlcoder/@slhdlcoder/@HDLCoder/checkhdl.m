function varargout=checkhdl(this,params,htmlReport)





    slhdlcoder.checkLicense;
    hdlismatlabmode(0);

    if nargin<2
        params={};
    end

    if nargin<3
        htmlReport=false;
    end

    this.CalledFromMakehdl=(nargin>2);
    if~this.CalledFromMakehdl

        this.ChecksCatalog.remove(this.ChecksCatalog.keys());
        this.ChecksCatalog(this.ModelName)=[];
    end
    hs=initCheckhdl(this,this.CalledFromMakehdl,params);
    failed=this.createModelList;
    if failed
        if nargout==0
            this.ChecksCatalog(this.ModelName)
        end
        if nargout>=1
            varargout{1}=this.ChecksCatalog(this.ModelName);
        end
        if nargout>=2
            varargout{2}=[];
        end
        if nargout>=3
            varargout{3}=[];
        end
        return;
    end

    try
        hdldisp(message('hdlcoder:hdldisp:StartCheck',this.ModelName));
        this.CachedSingleTaskRateTransMsg=get_param(this.ModelName,...
        'SingleTaskRateTransMsg');


        if this.getParameter('BuildToProtectModel')&&...
            numel(this.ProtectedModels)>0
            error(message('hdlcoder:validate:ModelRefHasProtectedModel'));
        end



        arrayLayout=get_param(this.ModelName,'ArrayLayout');
        if strcmpi(arrayLayout,'Row-Major')
            error(message('hdlcoder:validate:MajorityUnsupportedClient'));
        end



        isFixedStepSTIndependent=strcmpi(get_param(this.ModelName,'SolverType'),'Fixed-step')&&strcmpi(get_param(this.ModelName,'SampleTimeConstraint'),'STIndependent');
        if~isFixedStepSTIndependent
            automaicRateTrnsition=get_param(this.ModelName,'AutoInsertRateTranBlk');
            if strcmpi(automaicRateTrnsition,'on')
                errObj=message('hdlcoder:validate:UnsupportedAutoInsertRateTransition',this.ModelName);
                this.addCheck(this.ModelName,'Warning',errObj);
            end
        end




        concurrentTasks=get_param(this.ModelName,'ConcurrentTasks');
        if strcmpi(concurrentTasks,'on')
            errObj=message('hdlcoder:validate:ConcurrentTasksNumericMismatch',this.ModelName);
            this.addCheck(this.ModelName,'Warning',errObj);
        end




        if~this.getParameter('GenerateHDLCode')
            errObj=message('hdlcoder:engine:NoCode');
            this.addCheck(this.Modelname,'Message',errObj);
        end



        if(strcmpi(this.getCLI.GenerateRecordType,'on')&&this.getParameter('isSystemVerilog'))
            errObj=message('hdlcoder:engine:RecordUnsupported');
            this.addCheck(this.Modelname,'Message',errObj);
        end





        if~this.getParameter('GenerateModel')
            if this.getParameter('GenerateValidationModel')
                this.setParameter('GenerateValidationModel',false);
            end
        end


        prefixNameGM=this.getParameter('GeneratedModelNamePrefix');
        suffixNameVNL=this.getParameter('ValidationModelNameSuffix');


        if this.getParameter('GenerateModel')
            if~isempty(prefixNameGM)
                gmMdlName=[prefixNameGM,this.ModelName];
                if length(gmMdlName)>namelengthmax
                    error(message('hdlcoder:validate:ExceedNameLengthMaxSize',gmMdlName,'generated model'));
                end
                if~isvarname(gmMdlName)
                    error(message('hdlcoder:validate:InvalidGMPrefixName'));
                end
            else
                error(message('hdlcoder:validate:InvalidGMPrefixName'));
            end



            if this.getParameter('GenerateValidationModel')
                if~isempty(suffixNameVNL)
                    gmPrefix=hdlget_param(this.ModelName,'GeneratedModelNamePrefix');
                    vnlMdlName=[gmPrefix,this.ModelName,suffixNameVNL];
                    if length(vnlMdlName)>namelengthmax
                        error(message('hdlcoder:validate:ExceedNameLengthMaxSize',vnlMdlName,'validation model'));
                    end
                    if~isvarname(vnlMdlName)
                        error(message('hdlcoder:validate:InvalidVNLSuffixName'));
                    end
                else
                    error(message('hdlcoder:validate:InvalidVNLSuffixName'));
                end
            end
        end


        hScaleVal=this.getParameter('InterBlkHorzScale');
        vScaleVal=this.getParameter('InterBlkVertScale');

        checkScaleValue(hScaleVal);
        checkScaleValue(vScaleVal);




        if this.isDutModelRef
            slbh=get_param(this.ModelName,'Handle');
            if isprop(slbh,'Type')&&strcmp(get_param(slbh,'Type'),'block_diagram')
                paramArgNames=get_param(slbh,'ParameterArgumentNames');
                if~isempty(paramArgNames)


                    if this.mdlIdx==0
                        this.mdlIdx=1;
                    end
                    error(message('hdlcoder:engine:toplevelgenericmodelref'));
                end
            end
        end


        iterativeSubsystemCheck(this);



        variantSubsystemCheck(this);




        this.tunableParamCheck;




        traceabilityCheck(this);




        numModels=this.createPir;









        if this.SkipFrontEnd
            closeconnection=(nargin<3);
            this.cleanup(hs,false,closeconnection);
            return;
        end





        global_checks=this.performGlobalChecks;




        for mdlIdx=numel(this.AllModels)-1:-1:1
            this.mdlIdx=mdlIdx;
            p=pir(this.AllModels(mdlIdx).modelName);
            this.forAllComponents(p,@updateSyntheticComp);
        end





        wantChecksInM=(nargout~=0);
        allStarcChecks=[];
        allStarcRules=[];
        checks_out=[];
        for mdlIdx=1:numModels
            mdlName=this.AllModels(mdlIdx).modelName;
            this.mdlIdx=mdlIdx;


            isTopModel=isequal(mdlName,this.ModelName);
            if(isTopModel)
                this.updateChecksCatalog(mdlName,global_checks);


                topName=this.ModelName;
                this.runHDLScriptsSanityChecks(topName);
            end

            [starcchk,starcrule]=...
            this.runCheckhdlOnModel(mdlName,this.AllModels(mdlIdx).slFrontEnd,...
            wantChecksInM,htmlReport,mdlIdx~=1);


            checks_out=cat(2,checks_out,this.ChecksCatalog(mdlName));

            if~isempty(starcchk)
                allStarcChecks=[allStarcChecks,starcchk];%#ok<AGROW>
            end
            if~isempty(starcrule)
                allStarcRules=[allStarcRules,starcrule];%#ok<AGROW>
            end
        end

        if nargout>=1
            varargout{1}=checks_out;
        end
        if nargout>=2
            varargout{2}=allStarcChecks;
        end
        if nargout>=3
            varargout{3}=allStarcRules;
        end

    catch me
        if strcmpi(me.identifier,'hdlcoder:validate:ModelRefProtectedModel')
            error(message('hdlcoder:validate:ModelRefProtectedModel'));
        end

        if~this.CalledFromMakehdl&&this.NeedToGenerateHTMLReport
            mdlName=this.AllModels(1).modelName;
            this.addCheck(mdlName,'Error',me);
            this.makehdlcheckreport(mdlName,this.ChecksCatalog(mdlName));
        end
        this.cleanup(hs,false);
        rethrow(me);
    end

    closeconnection=(nargin<3);
    this.cleanup(hs,false,closeconnection);
end

function checkScaleValue(val)
    if isfinite(val)&&~isempty(val)&&isscalar(val)
        if val<0
            error(message('HDLShared:CLI:invalidHVScaleValue'));
        end
    else
        error(message('HDLShared:CLI:invalidHVScaleValue'));
    end
end

function iterativeSubsystemCheck(this)

    if~isempty(find_system(this.getStartNodeName,'SearchDepth','1',...
        'FollowLinks','on','LookUnderMasks','all','BlockType','ForEach'))
        error(message('hdlcoder:validate:ForEachAsDUT',this.getStartNodeName));
    end


    if~isempty(find_system(this.getStartNodeName,'SearchDepth','1',...
        'FollowLinks','on','LookUnderMasks','all','BlockType','ForIterator'))
        error(message('hdlcoder:validate:ForIterAsDUT',this.getStartNodeName));
    end


    if~isempty(find_system(this.getStartNodeName,'SearchDepth','1',...
        'FollowLinks','on','LookUnderMasks','all','BlockType','Neighborhood'))
        error(message('hdlcoder:validate:NPUasDUT',this.getStartNodeName));
    end




    if slfeature('STVariantsInHDL')>0
        forEachBlocks=find_system(this.getStartNodeName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.startupVariants,...
        'FollowLinks','on','BlockType','ForEach');
    else
        forEachBlocks=find_system(this.getStartNodeName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on','BlockType','ForEach');
    end
    if~isempty(forEachBlocks)
        numMdls=numel(this.AllModels);

        for ii=1:numel(forEachBlocks)
            blk=forEachBlocks{ii};
            if any(strcmpi(get_param(blk,'SubsysMaskParameterPartition'),'on'))


                if this.mdlIdx==0
                    this.mdlIdx=numMdls;
                end
            end
        end
    end
end

function traceabilityCheck(this)




    if this.isDutModelRef
        if this.getParameter('traceability')||this.getParameter('TraceabilityProcessing')
            msg=message('hdlcoder:makehdl:TraceModelRefAsDUTNotSupported');
            this.addCheck(this.ModelName,'Warning',msg);

            this.setParameter('traceability',false);
            this.setParameter('TraceabilityProcessing',false);
        end
    end
end

function variantSubsystemCheck(this)





    inlineVariantBlocks=find_system(this.getStartNodeName,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.startupVariants,...
    'RegExp','on',...
    'FollowLinks','on','BlockType','\<VariantSource\>|\<VariantSink\>');

    vssBlocks=find_system(this.getStartNodeName,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.startupVariants,...
    'FollowLinks','on','BlockType','SubSystem','Variant','on');


    if~isempty(inlineVariantBlocks)
        for ii=1:numel(inlineVariantBlocks)
            blk=inlineVariantBlocks{ii};
            variantActivationTime=get_param(blk,'CompiledVariantActivationTime');
            if strcmpi(variantActivationTime,'startup')||...
                strcmpi(variantActivationTime,'code compile')
                error(message('hdlcoder:validate:UnsupportedVariantActivationTime',blk));
            end
        end
    end


    if~isempty(vssBlocks)
        for ii=1:numel(vssBlocks)
            blk=vssBlocks{ii};
            variantActivationTime=get_param(blk,'CompiledVariantActivationTime');
            if slfeature('STVariantsInHDL')>0
                if strcmpi(variantActivationTime,'code compile')
                    error(message('hdlcoder:validate:UnsupportedCCVariantActivationTime',blk));
                end

                if~strcmpi(variantActivationTime,'startup')
                    continue;
                end





                defaultKeyWordNotUsed=true;
                variantChoices=get_param(blk,'VariantChoices');
                for index=1:length(variantChoices)
                    if strcmp(variantChoices(index).Name,'(default)')
                        defaultKeyWordNotUsed=false;
                        break;
                    end
                end


                if strcmp(get_param(blk,'AllowZeroVariantControls'),'off')&&defaultKeyWordNotUsed
                    error(message('hdlcoder:validate:UnsupportedUseOfAZVCOffinST',blk));
                end




                [slvarUsed,variantVariables]=slInternal('getVariantSSInfoForHDL',get_param(blk,'Handle'));
                if slvarUsed
                    error(message('hdlcoder:validate:UnsupportedUseOfSLVariants',blk));
                end
                for index=1:length(variantVariables)
                    ValidateVariantVariableValue(variantVariables{index},blk)
                end
                portHandles=get_param(blk,'PortHandles');



                for inPIndex=1:length(portHandles.Inport)
                    isVirtualBus=strcmp(get_param(portHandles.Inport(inPIndex),'CompiledBusType'),'VIRTUAL_BUS');
                    isNonVirtualBus=strcmp(get_param(portHandles.Inport(inPIndex),'CompiledBusType'),'NON_VIRTUAL_BUS');
                    if(isVirtualBus||isNonVirtualBus)
                        error(message('Simulink:Variants:UnsupportedUseOfBusWithvariants',blk));
                    end
                end
                for outPIndex=1:length(portHandles.Outport)
                    isVirtualBus=strcmp(get_param(portHandles.Outport(outPIndex),'CompiledBusType'),'VIRTUAL_BUS');
                    isNonVirtualBus=strcmp(get_param(portHandles.Outport(outPIndex),'CompiledBusType'),'NON_VIRTUAL_BUS');
                    if(isVirtualBus||isNonVirtualBus)
                        error(message('Simulink:Variants:UnsupportedUseOfBusWithvariants',blk));
                    end
                end
            else
                if strcmpi(variantActivationTime,'code compile')||strcmpi(variantActivationTime,'startup')
                    error(message('hdlcoder:validate:UnsupportedVariantActivationTime',blk));
                end
            end
        end
    end
end
function ValidateVariantVariableValue(variantVar,blk)
    variable=slResolve(variantVar,blk);
    if isa(variable,'Simulink.Parameter')
        dataType=variable.DataType;
    elseif isa(variable,'Simulink.VariantControl')
        dataType=class(variable.Value);
    else
        dataType=class(variable);
    end
    supportedDataTypes={'int8','uint8','int16','uint16','int32','uint32','logical'};
    index=ismember(supportedDataTypes,dataType);
    if~any(index)
        error(message('hdlcoder:validate:UnsupportedDataTypesUsedWithVariants',blk,variantVar,dataType));
    end
end


