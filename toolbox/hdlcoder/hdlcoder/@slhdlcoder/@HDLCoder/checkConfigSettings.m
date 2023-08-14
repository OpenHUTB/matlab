function checks=checkConfigSettings(this)





    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});


    rates=this.PirInstance.getModelSampleTimes;

    if all(rates<0)
        msg=message('hdlcoder:engine:inheritedsampletime');
        checks(1).path=this.getStartNodeName;
        checks(1).type='model';
        checks(1).message=msg.getString;
        checks(1).level='Warning';
        checks(1).MessageID=msg.Identifier;
    elseif all(rates==0)
        if targetcodegen.targetCodeGenerationUtils.isNFPMode()
            checks(1).level='Error';
            msg=message('hdlcommon:nativefloatingpoint:continuoussampletime');
        else
            checks(1).level='Warning';
            msg=message('hdlcoder:engine:continuoussampletime');
        end

        checks(1).path=this.getStartNodeName;
        checks(1).type='model';
        checks(1).message=msg.getString;
        checks(1).MessageID=msg.Identifier;
    else
        gp=pir;
        rates=gp.getDutSampleTimes;
        checks=slhdlcoder.solverCheck(this,rates,'Warning',this.CachedSingleTaskRateTransMsg,false);
    end




    haveCosim=~strcmpi(this.getParameter('generatecosimmodel'),'None');
    if haveCosim

        if this.getParameter('clockinputs')==2
            msg=message('hdlcoder:engine:cosimmodelmulticlock');
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end


        if~strcmpi(this.getParameter('NoResetInitializationMode'),'InsideModule')
            msg=message('hdlcoder:engine:cosimmodelnoresetinitmode');
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Warning';
            checks(end).MessageID=msg.Identifier;
        end
    end




    slbh=get_param(this.getStartNodeName,'handle');
    if isprop(get_param(slbh,'Object'),'BlockType')&&...
        strcmpi(get_param(slbh,'BlockType'),'SubSystem')&&...
        ~strcmpi(get_param(slbh,'SFBlockType'),'NONE')
        if sfprivate('is_truth_table_chart_block',slbh)
            kind='Truth Table';
        elseif sfprivate('is_eml_chart_block',slbh)
            kind='MATLAB Function Block';
        elseif sfprivate('is_reactive_testing_table_chart_block',slbh)
            kind='Test Sequence Block';
        else
            kind='Stateflow Chart';
        end
        if strcmp(kind,'MATLAB Function Block')&&strcmp(hdlfeature('HDLBlockAsDUT'),'on')

            this.AllowBlockAsDUT=true;
        else
            msg=message('hdlcoder:validate:TopLevelSF',kind);
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end
    end

    if this.nonTopDut&&this.mdlIdx==numel(this.AllModels)&&~this.AllowBlockAsDUT

        snn=this.OrigStartNodeName;
        hdldata=get_param(snn,'HDLData');
        if~isempty(hdldata)
            if~isempty(hdldata.archSelection)&&...
                (strcmp(get_param(snn,'BlockType'),'SubSystem')&&...
                ~strcmp(hdldata.archSelection,'Module'))
                error(message('hdlcoder:validate:DUTImplMustBeModule'));
            end
            subsys=hdldefaults.Subsystem;
            defaults=subsys.getImplParamDefaults;

            targetSpecParams={};
            for ii=1:numel(defaults)
                if strcmp(defaults{ii}.tabName,message('hdlcoder:hdlblockdialog:TargetSpecificationTab').getString)
                    targetSpecParams=[targetSpecParams,defaults{ii}.ImplParamName];%#ok<AGROW>
                end
            end
        end
    end




    if((this.nonTopDut&&strcmp(hdlfeature('NonTopNoModelReference'),'off'))||this.isDutModelRef)&&this.mdlIdx==numel(this.AllModels)

        if strcmp(get_param(snn,'Mask'),'on')&&...
            (~isempty(get_param(snn,'MaskTunableValues'))||...
            ~isempty(get_param(snn,'MaskInitialization')))
            msg=message('hdlcoder:validate:MaskOnNonTopLevel');
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end


        blkdiagram=this.getStartNodeName;
        while~isempty(get_param(blkdiagram,'Parent'))
            blkdiagram=get_param(blkdiagram,'Parent');
            if strcmp(get_param(blkdiagram,'Type'),'block')&&...
                strcmp(get_param(blkdiagram,'BlockType'),'SubSystem')&&...
                strcmp(get_param(blkdiagram,'Mask'),'on')
                if~isempty(get_param(blkdiagram,'MaskTunableValues'))||...
                    ~isempty(get_param(blkdiagram,'MaskInitialization'))




                    msg=message('hdlcoder:validate:ParentMaskOnNonTopLevel',blkdiagram);
                    checks(end+1).path=this.getStartNodeName;%#ok<AGROW>
                    checks(end).type='model';
                    checks(end).message=msg.getString;
                    checks(end).level='Error';
                    checks(end).MessageID=msg.Identifier;
                    break;
                end
            end
        end

        if strcmp(get_param(this.ModelName,'InlineParams'),'off')
            inline_param_msg=message('hdlcoder:validate:optDefaultParamBehaviorName').getString();
            msg=message('hdlcoder:validate:InlineParamsNonTopDUT',inline_param_msg,this.ModelName);
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        infRatePortName=this.checkForInfRatePorts;
        if~isempty(infRatePortName)
            msg=message('hdlcoder:engine:NonTopDUTInfRate',infRatePortName);
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Warning';
            checks(end).MessageID=msg.Identifier;
        end
    end




    numModels=numel(this.AllModels);
    if numModels>1

        if this.getParameter('MulticyclePathInfo')==1
            msg=message('hdlcoder:validate:MultiModelMulticycleNotSupported');
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end



        if~isempty(this.DownstreamIntegrationDriver)
            hDI=this.DownstreamIntegrationDriver;
            if hDI.isIPCoreGen&&...
                ~hDI.isVivado&&...
                strcmpi(this.getParameter('target_language'),'VHDL')
                msg=message('hdlcoder:validate:ModelRefIPCoreUnsupported');
                checks(end+1).path=this.ModelName;
                checks(end).type='model';
                checks(end).message=msg.getString;
                checks(end).level='Error';
                checks(end).MessageID=msg.Identifier;
            end
        end



        modelHDLDataMap=containers.Map;
        modelFirstInstMap=containers.Map;
        for ii=1:numModels
            mdlName=this.AllModels(ii).modelName;
            mrBlocks=find_system(mdlName,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
            'FollowLinks','on','BlockType','ModelReference');

            for jj=1:numel(mrBlocks)
                hdldata=get_param(mrBlocks{jj},'HDLData');
                if~isempty(hdldata)&&strcmp(hdldata.archSelection,'ModelReference')
                    if strcmp(get_param(mrBlocks{jj},'ProtectedModel'),'on')
                        modelFile=get_param(mrBlocks{jj},'ModelFile');
                        [~,refMdlName,~]=fileparts(modelFile);
                    else
                        refMdlName=get_param(mrBlocks{jj},'ModelName');
                    end

                    if~modelHDLDataMap.isKey(refMdlName)
                        modelHDLDataMap(refMdlName)=hdldata;
                        modelFirstInstMap(refMdlName)=mrBlocks{jj};
                    else


                        if~isequal(hdldata.archImplInfo,modelHDLDataMap(refMdlName).archImplInfo)


                            msg=message('hdlcoder:validate:ModelRefInstMustMatch',...
                            modelFirstInstMap(refMdlName),mrBlocks{jj});
                            checks(end+1).path=mrBlocks{jj};%#ok<AGROW>
                            checks(end).type='block';
                            checks(end).message=msg.getString;
                            checks(end).level='Error';
                            checks(end).MessageID=msg.Identifier;
                        end
                    end
                end
            end
        end
    end




    tac=this.getParameter('triggerasclock');
    if tac
        asyncReset=this.getParameter('async_reset');
        if asyncReset==0
            msg=message('hdlcoder:validate:TriggerAsClockReset');
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end
    end




    i18nchecks=slhdlcoder.HDLCoder.i18nParameterChecks(this);
    checks=[checks;i18nchecks];




    if isempty(this.getParameter('vhdl_library_name'))
        msg=message('hdlcoder:validate:VHDLLibraryNameEmpty');
        checks(end+1).path=this.getStartNodeName;
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).level='Error';
        checks(end).MessageID=msg.Identifier;
    end




    mgr=this.getParameter('minimizeglobalresets');
    if mgr
        nrim=this.getParameter('noresetinitializationmode');
        if strcmpi(nrim,'script')
            msg=message('hdlcoder:validate:NoResetUsingScript');
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Warning';
            checks(end).MessageID=msg.Identifier;
        end
    end




    inlineConfig=this.getParameter('isvhdl')&&...
    this.getParameter('inline_configurations')==0;
    if inlineConfig==1
        msg=message('hdlcoder:validate:InlineConfigsDisabled');
        checks(end+1).path=this.ModelName;
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).level='Warning';
        checks(end).MessageID=msg.Identifier;
    end






    db=this.getParameter('MulticyclePathInfo');
    if db
        msg1=message('hdlcoder:validate:MulticyclePathInfoCLIMessage');
        msg2=message('hdlcoder:validate:MulticyclePathInfoDeprecate',msg1.getString);
        checks(end+1).path=this.ModelName;
        checks(end).type='model';
        checks(end).message=msg2.getString;
        checks(end).level='Warning';
        checks(end).MessageID=msg2.Identifier;
    end





    if this.getParameter('EnableTestpoints')&&this.getParameter('ClockRatePipelineOutputPorts')
        msg=message('hdlcoder:makehdl:EnableTestpointsforCRPOutputports');
        checks(end+1).path=this.getStartNodeName;
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).level='Warning';
        checks(end).MessageID='hdlcoder:makehdl:EnableTestpointsforCRPOutputports';
    end





    if(this.getParameter('clockinputs')~=1)&&this.getParameter('ClockRatePipelining')
        msg=message('hdlcoder:validate:CRPWithMultipleClocks',this.ModelName);
        checks(end+1).path=this.ModelName;
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).level='Warning';
        checks(end).MessageID='hdlcoder:validate:CRPWithMultipleClocks';
    end




    if~(this.getParameter('balancedelays'))
        msg=message('hdlcoder:validate:GlobalDelayBalancingOff',this.ModelName);
        checks(end+1).path=this.ModelName;
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).level='Message';
        checks(end).MessageID='hdlcoder:validate:GlobalDelayBalancingOff';
    end




    hTopN=this.PirInstance.getTopNetwork;
    for ii=1:hTopN.NumberOfPirInputPorts
        hT=hTopN.PirInputSignals(ii).Type;


        if hT.isMatrix
            this.hasMatrixPortAtDUT=true;
        end


        if this.hasMatrixPortAtDUT&&strcmp(hdlfeature('EnableMatrixAtDUT'),'off')&&~this.getParameter('FrameToSampleConversion')
            pName=hTopN.PirInputPorts(ii).Name;
            msg=message('hdlcoder:engine:MatrixPortUnsupported',pName);
            checks(end+1).path=[this.getStartNodeName,'/',pName];%#ok<AGROW>
            checks(end).type='block';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        elseif hT.isRecordType
            memberTypes=hT.MemberTypesFlattened;
            for jj=1:numel(memberTypes)
                if memberTypes(jj).isMatrix
                    pName=hTopN.PirInputPorts(ii).Name;
                    fName=hT.MemberNamesFlattened{jj};
                    msg=message('hdlcoder:matrix:RecordDUTPort',pName,fName);
                    checks(end+1).path=[this.getStartNodeName,'/',pName];%#ok<AGROW>
                    checks(end).type='block';
                    checks(end).message=msg.getString;
                    checks(end).level='Error';
                    checks(end).MessageID=msg.Identifier;
                end
            end
        elseif this.getParameter('FrameToSampleConversion')&&hTopN.PirInputPorts(ii).hasStreamingMatrixTag

            if~hT.isArrayType
                pName=hTopN.PirInputPorts(ii).Name;
                msg=message('hdlcommon:streamingmatrix:PortError_ScalarStreamedSignal',pName);
                checks(end+1).path=[this.getStartNodeName,'/',pName];%#ok<AGROW> 
                checks(end).type='block';
                checks(end).message=msg.getString;
                checks(end).level='Error';
                checks(end).MessageID=msg.Identifier;
            else
                samplesPerCycle=this.getParameter('SamplesPerCycle');
                if hT.is3DMatrix
                    numCols=hT.Dimensions(2);

                    pName=hTopN.PirInputPorts(ii).Name;
                    msg=message('hdlcommon:streamingmatrix:PortError_3DInput',pName);
                    checks(end+1).path=[this.getStartNodeName,'/',pName];%#ok<AGROW>
                    checks(end).type='block';
                    checks(end).message=msg.getString;
                    checks(end).level='Error';
                    checks(end).MessageID=msg.Identifier;
                elseif hT.is2DMatrix
                    numCols=hT.Dimensions(2);
                elseif hT.isRowVector
                    numCols=hT.Dimensions;
                else
                    numCols=1;
                end
                if numCols<=samplesPerCycle
                    pName=hTopN.PirInputPorts(ii).Name;
                    msg=message('hdlcommon:streamingmatrix:PortError_MatrixColsLessThanSampleNum',pName,numCols,samplesPerCycle);
                    checks(end+1).path=[this.getStartNodeName,'/',pName];%#ok<AGROW>
                    checks(end).type='block';
                    checks(end).message=msg.getString;
                    checks(end).level='Error';
                    checks(end).MessageID=msg.Identifier;
                elseif rem(numCols,samplesPerCycle)~=0
                    pName=hTopN.PirInputPorts(ii).Name;
                    msg=message('hdlcommon:streamingmatrix:PortError_DivisibleBySampleNum',pName,numCols,samplesPerCycle);
                    checks(end+1).path=[this.getStartNodeName,'/',pName];%#ok<AGROW>
                    checks(end).type='block';
                    checks(end).message=msg.getString;
                    checks(end).level='Error';
                    checks(end).MessageID=msg.Identifier;
                end
            end
        end
    end

    for ii=1:hTopN.NumberOfPirOutputPorts
        hT=hTopN.PirOutputSignals(ii).Type;

        if hT.isMatrix
            if strcmp(hdlfeature('EnableMatrixAtDUT'),'off')&&~this.getParameter('FrameToSampleConversion')
                this.hasMatrixPortAtDUT=true;
                pName=hTopN.PirOutputPorts(ii).Name;
                msg=message('hdlcoder:engine:MatrixPortUnsupported',pName);

                checks(end+1).path=[this.getStartNodeName,'/',pName];%#ok<AGROW>
                checks(end).type='block';
                checks(end).message=msg.getString;
                checks(end).level='Error';
                checks(end).MessageID=msg.Identifier;
            end
            this.hasMatrixPortAtDUT=true;
        end
    end




    if this.getParameter('BuildToProtectModel')

        if this.getParameter('clockinputs')==2
            msg=message('hdlcoder:validate:ProtectModelWithMultiClock',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        if this.getParameter('minimizeclockenables')
            msg=message('hdlcoder:validate:ProtectModelWithMinimizeClockEnables',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        if~isempty(this.getParameter('module_prefix'))
            msg=message('hdlcoder:validate:ProtectModelWithModulePrefix',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        if(this.getParameter('triggerasclock'))
            msg=message('hdlcoder:validate:ProtectModelWithTriggerAsClock',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        if this.getParameter('ClockRatePipelineOutputPorts')
            msg=message('hdlcoder:validate:ProtectModelWithCRPAtOutputPorts',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        if this.getParameter('MaskParameterAsGeneric')
            msg=message('hdlcoder:validate:ProtectModelWithMaskParameterAsGeneric',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        numModels=numel(this.AllModels);
        if numModels>1
            for ii=1:numModels
                mdlName=this.AllModels(ii).modelName;
                mrBlocks=find_system(mdlName,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
                'FollowLinks','on','BlockType','ModelReference');
                for jj=1:numel(mrBlocks)
                    mrBlockName=mrBlocks{jj};
                    hC=get_param(mrBlockName,'handle');
                    if~isempty(get_param(hC,'ParameterArgumentValues'))
                        msg=message('hdlcoder:validate:ProtectModelWithModelArguments',mrBlockName);
                        checks(end+1).path=mrBlockName;%#ok<AGROW>
                        checks(end).type='model';
                        checks(end).message=msg.getString;
                        checks(end).level='Error';
                        checks(end).MessageID=msg.Identifier;
                    end
                end
            end
        end

    elseif~isempty(this.ProtectedModels)

        if this.getParameter('clockinputs')==2
            msg=message('hdlcoder:validate:MultiClockWithProtectedModels',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        if this.getParameter('minimizeclockenables')
            msg=message('hdlcoder:validate:MinimizeClockEnablesWithProtectedModels',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end


        if~isempty(this.getParameter('module_prefix'))&&...
            (isempty(this.DownstreamIntegrationDriver)||...
            ~this.DownstreamIntegrationDriver.isIPCoreGen)
            msg=message('hdlcoder:validate:ModulePrefixWithProtectedModels',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        if(this.getParameter('triggerasclock'))
            msg=message('hdlcoder:validate:TriggerAsClockWithProtectedModels',this.ModelName);
            checks(end+1).path=this.ModelName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end
    end

end


