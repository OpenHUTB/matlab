function drawSLBlockFromPirComp(this,tgtParentPath,hC)





    if isempty(hC.Name)
        blkname='t';
    else
        blkname=hC.Name;
    end


    slBlockName=hdlfixblockname(['',tgtParentPath,'/',blkname,'']);

    aOriginalValue=slfeature('ReportMaskEditTimeErrorsFromSetParam',0);

    try
        if hC.isNetworkInstance
            if hC.hasModelGenForNICTag
                drawSLBlockForNIC(this,tgtParentPath,hC,slBlockName);
            elseif hC.isSyntheticRam
                syntheticRamType=hC.getSyntheticRamTypeString;
                switch syntheticRamType
                case{'Simple Dual Port RAM','Dual Port RAM','Single Port RAM'}
                    drawSyntheticRamComp(this,slBlockName,hC,syntheticRamType)
                otherwise


                    assert(false,['unsupported synthetic RAM type: ',syntheticRamType]);
                end
            elseif hC.isSyntheticCordicBlock
                fcn=hC.getSyntheticCordicTypeString;
                iterNum=hC.getSyntheticCordicIterations;
                usePipelines=hC.getSyntheticCordicPipelined;
                switch fcn
                case{'sin','cos','sincos'}
                    srcBlock='hdlsllib/Math Operations/Trigonometric Function';

                    newSlSubsystemName=drawPirSubsystem(this,slBlockName,hC);

                    slpir.PIR2SL.drawCordicTrigBlocks(hC,srcBlock,newSlSubsystemName,fcn,iterNum,usePipelines);
                otherwise

                    assert(false,['unsupported synthetic CORDIC function: ',fcn]);
                end
            else

                drawNtwkInstanceComp(this,slBlockName,hC)
            end
        elseif hC.isCtxReference
            drawCtxRefComp(this,slBlockName,hC)
        else

            drawPirNativeComp(this,slBlockName,hC);
        end
    catch exp
        slfeature('ReportMaskEditTimeErrorsFromSetParam',aOriginalValue);
        rethrow(exp);
    end

    slfeature('ReportMaskEditTimeErrorsFromSetParam',aOriginalValue);

end


function drawNtwkInstanceComp(this,slBlockName,hNIC)
    hRefNtwk=hNIC.ReferenceNetwork;

    if~hRefNtwk.renderCodegenPir&&(hRefNtwk.isMaskedSubsystemLibBlock||...
        hRefNtwk.isBusExpansionSubsystem)
        drawSLBlock(this,slBlockName,hNIC);
        return;
    end

    if hNIC.Synthetic
        slBlockName=drawPirSubsystem(this,slBlockName,hNIC);
    else
        if hRefNtwk.Synthetic
            drawSLBlock(this,slBlockName,hNIC);
        else
            drawSubsystemSmart(this,slBlockName,hNIC);
            return;
        end
    end
    drawNetwork(this,slBlockName,hRefNtwk);
end


function slBlockName=drawSubsystemSmart(this,slBlockName,hNIC)
    hRefNtwk=hNIC.ReferenceNetwork;
    mkey=hRefNtwk.getErrorId();
    if(this.subsystemCache.isKey(mkey))
        subsystemPath=this.subsystemCache(mkey);
        [slBlockName,slHandle]=addBlock(this,hNIC,subsystemPath,slBlockName);
        setProperties(this,hNIC,slHandle);
    else
        slBlockName=drawSLSubsystem(this,slBlockName,hNIC);
        drawNetwork(this,slBlockName,hRefNtwk);


        if hRefNtwk.NumberOfPirGenericPorts==0&&hRefNtwk.UsesGenericPorts==false
            this.subsystemCache(mkey)=slBlockName;
        end
    end
end


function newSlBlockName=drawPirNativeComp(this,slBlockName,hC)

    newSlBlockName=drawPirNativeCompCore(this,slBlockName,hC);
    if(~isempty(hC)&&~hC.isAnnotation)
        name=get_param(newSlBlockName,'Name');
        name=strrep(name,'/','//');
        hC.Name=name;
    end
end

function newSlBlockName=drawPirNativeCompCore(this,slBlockName,hC)
    compType=hC.ClassName;
    newSlBlockName=slBlockName;



    if strcmp(compType,'black_box_comp')
        newSlBlockName=slpir.PIR2SL.getUniqueName(slBlockName);
        hC.generateSLBlock(newSlBlockName);
    elseif strcmp(compType,'filter_comp')
        newSlBlockName=drawFilterComp(this,slBlockName,hC);
    elseif strcmp(compType,'recip_comp')
        newSlBlockName=drawRecipComp(this,slBlockName,hC);
    elseif strcmp(compType,'recip_sqrtnewton_comp')
        newSlBlockName=slpir.PIR2SL.getUniqueName(slBlockName);
        newSlBlockName=drawRecipSqrtNewtonComp(this,newSlBlockName,hC);
    elseif strcmp(compType,'sqrtnewton_comp')
        newSlBlockName=slpir.PIR2SL.getUniqueName(slBlockName);
        newSlBlockName=drawSqrtNewtonComp(this,newSlBlockName,hC);
    elseif strcmp(compType,'complex_conjugate_comp')
        newSlBlockName=drawCplxConjugateComp(this,slBlockName,hC);
    elseif any(strcmp(compType,{'target_trig_comp','target_trig2_comp'}))
        newSlBlockName=drawTargetTrigComp(this,slBlockName,hC);
    elseif hC.getIsTarget

        newSlBlockName=drawTargetComp(this,slBlockName,hC);
    elseif(~hC.Synthetic)
        newSlBlockName=drawSLBlock(this,slBlockName,hC);
    elseif hC.shouldDraw
        try
            switch compType
            case{'rtw_comp'}
                newSlBlockName=drawSLBlock(this,slBlockName,hC);
            case{'eml_comp'}
                newSlBlockName=drawEMLComp(this,slBlockName,hC);
            case{'abs_comp'}
                newSlBlockName=drawAbsComp(this,slBlockName,hC);
            case{'uminus_comp'}
                newSlBlockName=drawUnaryMinusComp(this,slBlockName,hC);
            case{'mul_comp'}
                newSlBlockName=drawMulComp(this,slBlockName,hC);
            case{'data_conv_comp'}
                newSlBlockName=drawDataConvComp(this,slBlockName,hC);
            case{'add_comp'}
                newSlBlockName=drawSumComp(this,slBlockName,hC);
            case{'gain_comp'}
                newSlBlockName=drawGainComp(this,slBlockName,hC);
            case{'assignment_comp'}
                newSlBlockName=drawAssignmentComp(this,slBlockName,hC);
            case{'integerdelay_comp'}
                newSlBlockName=drawIntegerDelayComp(this,slBlockName,hC);
            case{'ratetransition_comp'}
                newSlBlockName=drawRateTransitionComp(this,slBlockName,hC);
            case{'upsample_comp'}
                newSlBlockName=drawSampleChangeComp(this,slBlockName,hC);
            case{'downsample_comp'}
                newSlBlockName=drawSampleChangeComp(this,slBlockName,hC);
            case{'serializer_comp'}
                newSlBlockName=drawSerializerComp(this,slBlockName,hC);
            case{'deserializer_comp'}
                newSlBlockName=drawDeserializerComp(this,slBlockName,hC);
            case{'serializer1d_comp'}
                newSlBlockName=drawSerializer1DComp(this,slBlockName,hC);
            case{'deserializer1d_comp'}
                newSlBlockName=drawDeserializer1DComp(this,slBlockName,hC);
            case{'dynamic_shift_comp'}
                newSlBlockName=drawDynamicShiftComp(this,slBlockName,hC);
            case{'mux_comp'}
                newSlBlockName=drawMuxComp(this,slBlockName,hC);
            case{'switch_comp'}
                newSlBlockName=drawSwitchComp(this,slBlockName,hC);
            case{'multiportswitch_comp'}
                newSlBlockName=drawMultiPortSwitchComp(this,slBlockName,hC);
            case{'selector_comp'}
                newSlBlockName=drawSelectorComp(this,slBlockName,hC);
            case{'concat_comp'}
                newSlBlockName=drawConcatComp(this,slBlockName,hC);
            case{'bitextract_comp'}
                newSlBlockName=drawBitExtractComp(this,slBlockName,hC);
            case{'bitconcat_comp'}
                newSlBlockName=drawBitConcatComp(this,slBlockName,hC);
            case{'bitwiseop_comp'}
                newSlBlockName=drawBitwiseOpComp(this,slBlockName,hC);
            case{'split_comp'}
                newSlBlockName=drawSplitComp(this,slBlockName,hC);
            case{'reshape_comp'}
                newSlBlockName=drawReshapeComp(this,slBlockName,hC);
            case{'comparetoconst_comp'}
                newSlBlockName=drawCompareToValueComp(this,slBlockName,hC);
            case{'ram_single_comp'}
                newSlBlockName=drawRamComp(this,slBlockName,hC);
            case{'mconstant_comp'}
                newSlBlockName=drawConstComp(this,slBlockName,hC);
            case{'const_comp'}
                newSlBlockName=drawPirConstComp(this,slBlockName,hC);
            case{'unitdelayenabled_comp'}
                newSlBlockName=drawUnitDelayEnabledComp(this,slBlockName,hC);
            case{'unitdelayenabledresettable_comp'}
                newSlBlockName=drawUnitDelayEnabledResettableComp(this,slBlockName,hC);
            case{'integerdelayenabledresettable_comp'}
                newSlBlockName=drawIntDelayEnabledResettableComp(this,slBlockName,hC);
            case{'tappeddelay_comp'}
                newSlBlockName=drawTappedDelayComp(this,slBlockName,hC);
            case{'tappeddelayenabledresettable_comp'}
                newSlBlockName=drawTappedDelayEnabledResettableComp(this,slBlockName,hC);
            case{'saturation_comp'}
                newSlBlockName=drawSaturationComp(this,slBlockName,hC);
            case{'bitset_comp'}
                newSlBlockName=drawBitsetComp(this,slBlockName,hC);
            case{'bitshift_comp'}
                newSlBlockName=drawBitShiftComp(this,slBlockName,hC);
            case{'counterlimited_comp'}
                newSlBlockName=drawCounterLimitedComp(this,slBlockName,hC);
            case{'counterfreerunning_comp'}
                newSlBlockName=drawCounterFreeRunningComp(this,slBlockName,hC);
            case{'hdlcounter_comp'}
                newSlBlockName=drawHDLCounterComp(this,slBlockName,hC);
            case{'minmax_comp'}
                newSlBlockName=drawMinMaxComp(this,slBlockName,hC);
            case{'dataunbuffer_comp'}
                newSlBlockName=drawDataUnbufferComp(this,slBlockName,hC);
            case{'hwdemux_comp'}
                newSlBlockName=drawDemuxComp(this,slBlockName,hC);
            case{'filter_comp'}
                newSlBlockName=drawFilterComp(this,slBlockName,hC);
            case{'logic_comp'}
                newSlBlockName=drawLogicComp(this,slBlockName,hC);
            case{'ratechange_comp'}
                newSlBlockName=drawRepeatComp(this,slBlockName,hC);
            case{'relop_comp'}
                newSlBlockName=drawRelopComp(this,slBlockName,hC);
            case{'prelookuptable_comp'}
                newSlBlockName=drawCompFromSLHandle(this,slBlockName,hC);
            case{'directlookuptable_comp'}
                newSlBlockName=drawDirectLookupTableComp(this,slBlockName,hC);
            case{'lookuptable_comp'}
                newSlBlockName=drawLookupTableComp(this,slBlockName,hC);
            case{'buscreator_comp'}
                newSlBlockName=drawBusCreatorComp(this,slBlockName,hC);
            case{'busselector_comp'}
                newSlBlockName=drawBusSelectorComp(this,slBlockName,hC);
            case{'annotation_comp'}
                newSlBlockName=drawTerminatorComp(this,slBlockName,hC);
            case{'hitcross_comp'}
                newSlBlockName=drawHitCrossComp(this,slBlockName,hC);
            case{'backlash_comp'}
                newSlBlockName=drawBacklashComp(this,slBlockName,hC);
            case{'sqrt_comp'}
                newSlBlockName=drawMathFuncComp(this,slBlockName,hC);
            case{'math_comp'}
                newSlBlockName=drawMathFuncComp(this,slBlockName,hC);
            case{'trig_comp'}
                newSlBlockName=drawMathFuncComp(this,slBlockName,hC);
            case{'transpose_comp'}
                newSlBlockName=drawTransposeComp(this,slBlockName,hC);
            case{'hermitian_comp'}
                newSlBlockName=drawHermitianComp(this,slBlockName,hC);
            case{'buffer_comp'}
                newSlBlockName=drawBufferComp(this,slBlockName,hC);
            case{'c2ri_comp'}
                newSlBlockName=drawComplex2RealImag(this,slBlockName,hC);
            case{'ri2c_comp'}
                newSlBlockName=drawRealImag2Complex(this,slBlockName,hC);
            case{'scalarmac_comp'}
                newSlBlockName=drawScalarMacComp(this,slBlockName,hC);
            case{'vectormac_comp'}
                newSlBlockName=drawVectorMacComp(this,slBlockName,hC);
            case{'streamingmac_comp'}
                newSlBlockName=drawStreamingMacComp(this,slBlockName,hC);
            case{'assertion_comp'}
                newSlBlockName=drawAssertionComp(this,slBlockName,hC);
            case{'unitdelay_comp'}
                newSlBlockName=drawUnitDelayComp(this,slBlockName,hC);
            case{'index_comp'}
                newSlBlockName=drawIndexComp(this,slBlockName,hC);
            case{'signum_comp'}
                newSlBlockName=drawSignumComp(this,slBlockName,hC);
            case{'deadzone_comp'}



                atomicParams=true;
                newSlBlockName=drawComp(this,slBlockName,hC,atomicParams);
            otherwise
                newSlBlockName=drawComp(this,slBlockName,hC);
            end
        catch me
            hdldisp(getReport(me),0);


            warnObj=message('hdlcoder:engine:MdlGenCompError',hC.Name);
            warning(warnObj);
            this.reportCheck('Error',warnObj);
        end
    end

    if~isempty(newSlBlockName)&&...
        ~isempty(hC)
        try



            if hC.getIsTarget
                gmhCHandle=get_param(get_param(newSlBlockName,'Parent'),'Handle');
            else
                gmhCHandle=get_param(newSlBlockName,'Handle');
            end

            if~isempty(gmhCHandle)
                hC.setGMHandle(gmhCHandle);
            end
        catch
        end
    end
end



function newSlBlockName=drawComp(this,slBlockName,hC,atomicParams,blk,lib,format)
    newSlBlockName=slBlockName;

    if nargin<7
        format=true;
    end

    if nargin<6
        lib=hC.getLibraryName;
    end

    if nargin<5
        blk=hC.getBlockName;
    end

    if nargin<4
        atomicParams=false;
    end

    if~isempty(lib)&&~isempty(blk)



        invalidBlockLoadWarning_setting=warning('query','Simulink:Commands:LoadMdlInvalidBuiltInBlockType');
        warning('off','Simulink:Commands:LoadMdlInvalidBuiltInBlockType');

        load_system(lib);

        warning(invalidBlockLoadWarning_setting.state,'Simulink:Commands:LoadMdlInvalidBuiltInBlockType');

        newSlBlockName=addBlock(this,hC,blk,slBlockName);
        setParams(this,newSlBlockName,hC,atomicParams,format);
    end
end


function setParams(this,slBlockName,hC,atomicParams,format)
    if nargin<5
        format=true;
    end

    if nargin<4
        atomicParams=false;
    end

    if atomicParams
        setBlockParamsAtomically(this,slBlockName,hC,format);
    else
        setBlockParams(this,slBlockName,hC,format);
    end
end


function setSampleTime(this,slBlockName,hC,paramname)
    if(nargin<4)
        paramname='SampleTime';
    end

    setsSmpTime=hC.setsOutputSampleRate;
    if~setsSmpTime
        return;
    end

    setSampleTimeCommon(this,slBlockName,hC,paramname)
end


function setSampleTimeCommon(this,slBlockName,hC,paramname)

    if(nargin<4)
        paramname='SampleTime';
    end

    if hC.isParentTriggeredSubsystem()

        set_param(slBlockName,paramname,'-1');
    else
        out=hC.PirOutputSignals(1);
        if this.OverrideSampleTime
            st=this.SampleTime;
        else
            st=out.SimulinkRate;
        end
        if~isinf(st)
            set_param(slBlockName,paramname,sprintf('%16.15g',st));
        end
    end
end


function pvpairs=setBlockParamsCommon(this,slBlockName,hC)
    setsOutType=hC.setsOutputDataTypeStr;
    if setsOutType
        out=hC.PirOutputSignals(1);
        setDataTypeParam(this,slBlockName,out.Type);
    end
    setSampleTime(this,slBlockName,hC);

    pvpairs=hC.getSLParams;
end


function setBlockParams(this,slBlockName,hC,format)
    pvpairs=setBlockParamsCommon(this,slBlockName,hC);
    if isempty(pvpairs)||~iscell(pvpairs)
        return;
    end

    num=length(pvpairs);
    for ii=1:2:num
        propname=pvpairs{ii};
        propval=pvpairs{ii+1};
        if~isempty(propname)&&~isempty(propval)
            if(isnumeric(propval)||isfloat(propval)||islogical(propval))&&format
                propval=formatVal(this,propval);
            elseif iscell(propval)&&format
                propval=formatCell(this,propval,false);
            end
            set_param(slBlockName,propname,propval);
        end
    end
end


function setBlockParamsAtomically(this,slBlockName,hC,format)
    pvpairs=setBlockParamsCommon(this,slBlockName,hC);
    if isempty(pvpairs)||~iscell(pvpairs)
        return;
    end

    num=length(pvpairs);
    pvpairStr=[];
    for ii=1:2:num
        propname=pvpairs{ii};
        propval=pvpairs{ii+1};

        if~isempty(propname)&&~isempty(propval)
            if(isnumeric(propval)||isfloat(propval)||islogical(propval))&&format
                propval=formatVal(this,propval,true);
            end
            if iscell(propval)
                propval=formatCell(this,propval,true);
                pvpairStr=sprintf('%s, ''%s'', %s',pvpairStr,propname,propval);
            else
                pvpairStr=sprintf('%s, ''%s'', ''%s''',pvpairStr,propname,propval);
            end
        end
    end
    setParamCmd=sprintf('set_param("%s"%s)',slBlockName,pvpairStr);
    eval(setParamCmd);
end


function setBoolParameter(slBlockName,paramName,paramVal)
    if paramVal
        set_param(slBlockName,paramName,'on');
    else
        set_param(slBlockName,paramName,'off');
    end
end




function newSlBlockName=drawTargetComp(this,slBlockName,hC)



    slBlockName=drawBlockSubsystem(this,slBlockName,hC);
    blkType=hC.ClassName;
    labelSubsystem(this,blkType,slBlockName);


    newSlBlockName=[slBlockName,'/',hC.Name];


    drawSpecificComp(this,blkType,newSlBlockName,hC);


    lastBlockPosition=setCompLayout(newSlBlockName);

    setCompInputConnections(slBlockName,hC);

    drawOutputDelayComp(this,slBlockName,hC,lastBlockPosition);
end

function newSlBlockName=drawTargetTrigComp(this,slBlockName,hC)

    newSlBlockName=drawTargetComp(this,slBlockName,hC);

    trigFuncName=hC.getFunctionName;
    if contains(['sin','cos','tan','sincos','cos + jsin'],trigFuncName)&&~hC.getNFPArgReduction


        componentPath=slpir.PIR2SL.getUniqueName([slBlockName,'/Input Check']);
        add_block('simulink/Model Verification/Check  Static Range',componentPath);
        componentName=get_param(componentPath,'Name');

        add_line(slBlockName,'In1/1',[componentName,'/1'],'AUTOROUTING','ON');

        dataType=hC.PirInputSignals(1).Type;
        if~strcmp(trigFuncName,'tan')
            bound='pi';
        else
            bound='pi/4';
        end


        if dataType.BaseType.getLeafType.isSingleType
            bound=['single(',bound,')'];
        end
        set_param(componentPath,'max',bound);
        set_param(componentPath,'min',['-',bound]);
        set_param(componentPath,'max_included','on');
        set_param(componentPath,'min_included','on');
        set_param(componentPath,'enabled','on');
        set_param(componentPath,'stopWhenAssertionFail','on');
    end
end


function drawSpecificComp(this,blkType,newSlBlockName,hC)


    try
        switch(blkType)
        case{'target_add_comp'}
            drawComp(this,newSlBlockName,hC);
        case{'target_mul_comp'}
            drawMulComp(this,newSlBlockName,hC);
        case{'target_conv_comp'}
            drawDataConvComp(this,newSlBlockName,hC);
        case{'target_relop_comp'}
            drawRelopComp(this,newSlBlockName,hC);
        case{'target_abs_comp'}
            drawComp(this,newSlBlockName,hC);
        case{'target_signum_comp'}
            drawComp(this,newSlBlockName,hC);
        case{'target_sqrt_comp'}
            drawNFPSqrtComp(this,newSlBlockName,hC);
        case{'target_hdlrecip_comp'}
            drawRecipComp(this,newSlBlockName,hC);
        case{'target_math_comp'}
            fname=hC.getFunctionName;

            if(strcmp(fname,'log2')||strcmp(fname,'pow2'))
                drawSLBlock(this,newSlBlockName,hC);
            else
                drawComp(this,newSlBlockName,hC);
            end
        case{'target_math2_comp'}
            drawComp(this,newSlBlockName,hC);
        case{'target_trig_comp'}
            drawComp(this,newSlBlockName,hC);
        case{'target_trig2_comp'}
            drawComp(this,newSlBlockName,hC);
        case{'target_trig3_comp'}
            drawComp(this,newSlBlockName,hC);
        case{'target_gain_pow2_comp'}
            drawGainComp(this,newSlBlockName,hC);
        case{'target_uminus_comp'}
            drawUnaryMinusComp(this,newSlBlockName,hC);
        case{'target_minmax_comp'}
            drawMinMaxComp(this,newSlBlockName,hC);
        case{'target_rounding_comp'}
            drawComp(this,newSlBlockName,hC);
        case{'nfpsparseconstmultiply_comp'}
            drawComp(this,newSlBlockName,hC);


            paramVal=formatVal(this,reshape(hC.getConstMatrix,hC.getConstMatrixSize));
            set_param(newSlBlockName,'constMatrix',paramVal);
        case{'target_scalarmac_comp'}
            if~(hC.getNFPFMA())
                drawComp(this,newSlBlockName,hC,false,'hdlsllib/HDL Operations/Multiply-Add','hdlsllib');
            else
                drawComp(this,newSlBlockName,hC,false,'hdlNFPMathLib/Fused Multiply-Add','hdlNFPMathLib');
            end
        otherwise
            error(message('hdlcommon:targetcodegen:UnsupportedBlock',blkType));
        end
    catch me
        rethrow(me);
    end
end


function lastBlockPosition=setCompLayout(slBlockName)
    set_param(slBlockName,'Orientation','right');
    blockPosition=[160,75,245,115];
    set_param(slBlockName,'Position',blockPosition);
    lastBlockPosition=[blockPosition(3),blockPosition(2)];
end


function setCompInputConnections(slBlockName,hC,idx)
    if nargin<3
        idx=1:length(hC.PirInputPorts);
    end

    for ii=idx
        oport=sprintf('In%i/1',ii);
        if hC.PirInputPorts(ii).isSubsystemTrigger
            iport=sprintf('%s/Trigger',hC.Name);
        else
            iport=sprintf('%s/%i',hC.Name,ii);
        end
        add_line(slBlockName,oport,iport,'autorouting','on');
    end
end


function setCompOutputConnections(slBlockName,hC,idx)
    if nargin<3
        idx=1:length(hC.PirOutputPorts);
    end

    for ii=idx
        iport=sprintf('Out%i/1',ii);
        oport=sprintf('%s/%i',hC.Name,ii);
        add_line(slBlockName,oport,iport,'autorouting','on');
    end
end


function outputDelayBlkName=drawOutputDelayComp(this,slBlockName,hC,lastBlockPosition)
    outputDelayBlkName=drawOutputDelayComp_inputDelay(this,slBlockName,hC,lastBlockPosition,hC.getPipelineDelay);
end

function outputDelayBlkName=drawOutputDelayComp_inputDelay(this,slBlockName,hC,lastBlockPosition,outDelay)
    outputDelayBlkName=slBlockName;
    move_down=[0,50];
    blkPosition=[lastBlockPosition(1)+50,lastBlockPosition(2)-move_down(2)];

    blkSize=[20,40];
    for ii=1:length(hC.PirOutputPorts)
        blkPosition=blkPosition+move_down;
        position=[blkPosition,blkPosition+blkSize];
        if outDelay>0
            outputDelayBlkName=[slBlockName,'/',hC.Name,'_pd',int2str(ii)];
            [outputDelayBlkName,~]=addBlock(this,[],'simulink/Discrete/Integer Delay',...
            outputDelayBlkName);
            set_param(outputDelayBlkName,'NumDelays',int2str(outDelay));
            set_param(outputDelayBlkName,'samptime',int2str(-1));
            set_param(outputDelayBlkName,'Position',position);
            set_param(outputDelayBlkName,'BackgroundColor',targetcodegen.basedriver.getBlockColor);
            delayname=get_param(outputDelayBlkName,'name');
            delayname=strrep(delayname,'/','//');
            delayout=[delayname,'/1'];
            add_line(slBlockName,[hC.Name,'/',int2str(ii)],delayout,'autorouting','on');
            add_line(slBlockName,delayout,['Out',int2str(ii),'/1'],'autorouting','on');
        else
            add_line(slBlockName,[hC.Name,'/',int2str(ii)],['Out',int2str(ii),'/1'],'autorouting','on');
        end
    end
end




function labelSubsystem(~,blkType,slBlockName)
    displayName=[];
    if targetcodegen.targetCodeGenerationUtils.isAlteraMode()
        displayName=targetcodegen.alteradriver.getMaskName(blkType);
    elseif targetcodegen.targetCodeGenerationUtils.isNFPMode()
        displayName=targetcodegen.nfpdriver.getMaskName(blkType);
    end
    if~isempty(displayName)
        displayNameCmd=sprintf('disp(''%s'');',displayName);
        set_param(slBlockName,'MaskDisplay',displayNameCmd);
    end
end


function newSlBlockName=drawBlockSubsystem(this,slBlockName,hC)


    newSlBlockName=addBlock(this,hC,'built-in/Subsystem',slBlockName);
    set_param(newSlBlockName,'BackgroundColor',targetcodegen.basedriver.getBlockColor);
    inportPath=cell(length(hC.PirInputPorts),1);
    for ii=1:length(hC.PirInputPorts)
        inportPath{ii}=[newSlBlockName,'/In',int2str(ii)];
        [inportName,~]=addBlock(this,[],'built-in/Inport',inportPath{ii});
        set_param(inportName,'Position',[85,78+((ii-1)*20),115,92+((ii-1)*20)]);
    end
    outportPath=cell(length(hC.PirOutputPorts),1);
    for ii=1:length(hC.PirOutputPorts)
        outportPath{ii}=[newSlBlockName,'/Out',int2str(ii)];
        [portName,~]=addBlock(this,[],'built-in/Outport',outportPath{ii});
        set_param(portName,'Position',[395,88+((ii-1)*20),425,102+((ii-1)*20)]);
    end
end


function newSlBlockName=drawBufferComp(this,slBlockName,hC,atomicParams)
    if nargin<4
        atomicParams=false;
    end

    newSlBlockName=drawBufferSourceComp(this,slBlockName,hC,atomicParams);
end


function newSlBlockName=drawBufferSourceComp(this,slBlockName,hC,atomicParams)
    sourceBlock=hC.getSourceBlock;
    switch sourceBlock
    case{'sigspec'}
        newSlBlockName=drawSignalSpecifactionBlock(this,slBlockName,hC,atomicParams);
    case{'reshape'}
        newSlBlockName=drawReshapeBlock(this,slBlockName,hC,atomicParams);
    otherwise
        newSlBlockName=drawComp(this,slBlockName,hC,atomicParams);
    end
end


function newSlBlockName=drawBufferCompCommon(this,lib,blk,slBlockName,hC,atomicParams)
    if~isempty(lib)&&~isempty(blk)
        load_system(lib);

        newSlBlockName=addBlock(this,hC,blk,slBlockName);
        setParams(this,newSlBlockName,hC,atomicParams);
    end
end


function newSlBlockName=drawComplex2RealImag(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);



    h=hC.OrigModelHandle;
    if h>0
        c2riObj=get_param(h,'Object');
    else
        c2riObj=[];
    end
    if~isempty(c2riObj)&&...
        (isa(c2riObj,'Simulink.ComplexToRealImag')||isprop(c2riObj,'Output'))
        mode=c2riObj.Output;
    else

        modeVal=hC.getMode;
        switch modeVal
        case 1
            mode='Real and imag';
        case 2
            mode='Real';
        case 3
            mode='Imag';
        end
    end
    set_param(newSlBlockName,'Output',mode);
end


function newSlBlockName=drawRealImag2Complex(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);



    h=hC.OrigModelHandle;
    if h>0
        ri2cObj=get_param(h,'Object');
    else
        ri2cObj=[];
    end
    if~isempty(ri2cObj)&&...
        (isa(ri2cObj,'Simulink.ComplexToRealImag')||isprop(ri2cObj,'Output'))
        mode=ri2cObj.Input;
    else

        modeVal=hC.getMode;
        switch modeVal
        case 1
            mode='Real and imag';
        case 2
            mode='Real';
        case 3
            mode='Imag';
        end
    end
    set_param(newSlBlockName,'Input',mode);
end


function newSlBlockName=drawSignalSpecifactionBlock(this,slBlockName,hC,atomicParams)
    newSlBlockName=drawBufferCompCommon(this,'simulink','built-in/SignalSpecification',...
    slBlockName,hC,atomicParams);
    hT=hC.PirInputSignals(1).Type;
    if~hT.BaseType.isRecordType
        set_param(newSlBlockName,'Dimensions',this.getDimensionsStr(hT));
        sltype=computeDataType(this,hT);
        setOutDataTypeStr(this,newSlBlockName,sltype);
    elseif(hC.OrigModelHandle>0)
        val=get_param(hC.OrigModelHandle,'Dimensions');
        set_param(newSlBlockName,'Dimensions',val);
    end
end


function newSlBlockName=drawReshapeBlock(this,slBlockName,hC,atomicParams)
    newSlBlockName=drawBufferCompCommon(this,'simulink','built-in/Reshape',...
    slBlockName,hC,atomicParams);
    hT=hC.PirOutputSignals(1).Type;
    if hT.isArrayType
        if hT.isMatrix
            outDimStr='Customize';
            newpropval="[";
            for kk=1:numel(hT.getDimensions)
                newpropval=newpropval+hT.Dimensions(kk)+",";
            end
            propval=extractBetween(newpropval,1,strlength(newpropval)-1)+"]";
            set_param(newSlBlockName,'OutputDimensions',propval);
        else
            if hT.isColumnVector
                outDimStr='Column vector (2-D)';
            elseif hT.isRowVector
                outDimStr='Row vector (2-D)';
            else
                outDimStr='1-D array';
            end
        end
    else
        outDimStr='1-D array';
    end
    set_param(newSlBlockName,'OutputDimensionality',outDimStr);
end


function newSlBlockName=drawRamComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    readNewData=hC.getReadNewData;
    if readNewData
        set_param(slBlockName,'dout_type','New data');
    else
        set_param(slBlockName,'dout_type','Old data');
    end
end


function newSlBlockName=drawFilterComp(this,slBlockName,hC)
    newSlBlockName=slpir.PIR2SL.getUniqueName(slBlockName);
    filterClass=hC.getFilterImpl;
    filterClass.generateSLBlock(hC,newSlBlockName);
end


function newSlBlockName=drawSerializer1DComp(this,slBlockName,hC)
    S=warning('OFF','hdlsllib:hdlsllib:singletaskingSolverSetting');

    usesHalfType=hC.PirInputSignals(1).Type.getLeafType.isHalfType;
    if usesHalfType
        newSlBlockName=drawBlockSubsystem(this,slBlockName,hC);
        serialBlockName=addBlock(this,[],'hdlsllib/HDL Operations/Serializer1D',[newSlBlockName,'/',hC.Name]);
    else
        newSlBlockName=drawComp(this,slBlockName,hC);
        serialBlockName=newSlBlockName;
    end

    setBoolParameter(serialBlockName,'validIn',hC.getValidInPort);
    setBoolParameter(serialBlockName,'startOut',hC.getStartOutPort);
    setBoolParameter(serialBlockName,'validOut',hC.getValidOutPort);

    set_param(serialBlockName,'Ratio',sprintf('%d',hC.getRatio));
    set_param(serialBlockName,'IdleCycles',sprintf('%d',hC.getIdleCycles));

    set_param(serialBlockName,'inputDataDimensions',sprintf('%d',hC.PirInputSignals(1).Type.getDimensions));

    sampleRate=hC.PirInputSignals(1).SimulinkRate;
    if(sampleRate==Inf)
        sampleTimeStr='-1';
    else
        sampleTimeStr=sprintf('%16.15g',sampleRate);
    end
    set_param(serialBlockName,'inputSampleTime',sampleTimeStr);

    types=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);

    complexDataType=types.iscomplex;

    if complexDataType
        set_param(serialBlockName,'inputSignalType','complex');
    else
        set_param(serialBlockName,'inputSignalType','real');
    end

    if usesHalfType


        addBlock(this,[],'hdlsllib/HDL Floating Point Operations/Float Typecast',[newSlBlockName,'/castHalfType']);
        addBlock(this,[],'hdlsllib/HDL Floating Point Operations/Float Typecast',[newSlBlockName,'/castToHalfType']);

        add_line(newSlBlockName,'In1/1','castHalfType/1');
        add_line(newSlBlockName,'castHalfType/1',[hC.Name,'/1']);
        add_line(newSlBlockName,[hC.Name,'/1'],'castToHalfType/1');
        add_line(newSlBlockName,'castToHalfType/1','Out1/1');
        Simulink.BlockDiagram.arrangeSystem(newSlBlockName);
    end

    warning(S.state,'hdlsllib:hdlsllib:singletaskingSolverSetting');
end


function newSlBlockName=drawDeserializer1DComp(this,slBlockName,hC)
    usesHalfType=hC.PirInputSignals(1).Type.getLeafType.isHalfType;
    if usesHalfType
        newSlBlockName=drawBlockSubsystem(this,slBlockName,hC);
        deserialBlockName=addBlock(this,[],'hdlsllib/HDL Operations/Deserializer1D',[newSlBlockName,'/',hC.Name]);
    else
        newSlBlockName=drawComp(this,slBlockName,hC);
        deserialBlockName=newSlBlockName;
    end
    setBoolParameter(deserialBlockName,'startIn',hC.getStartInPort);
    setBoolParameter(deserialBlockName,'validIn',hC.getValidInPort);
    setBoolParameter(deserialBlockName,'validOut',hC.getValidOutPort);

    set_param(deserialBlockName,'Ratio',sprintf('%d',hC.getRatio));
    set_param(deserialBlockName,'IdleCycles',sprintf('%d',hC.getIdleCycles));

    if~isempty(hC.getInitialValue)
        initialValue=hC.getInitialValue;

        assert(numel(initialValue)<2);
        className=class(initialValue);
        if isnumeric(initialValue)&&~isSLEnumType(className)


            set_param(deserialBlockName,'InitialCondition',num2str(initialValue));
        else

            set_param(deserialBlockName,'InitialCondition',formatVal(this,initialValue));
        end
    end

    set_param(deserialBlockName,'inputDataDimensions',...
    sprintf('%d',hC.PirInputSignals(1).Type.getDimensions));

    sampleRate=hC.PirInputSignals(1).SimulinkRate;
    if(sampleRate==Inf)
        sampleTimeStr='-1';
    else
        sampleTimeStr=sprintf('%16.15g',sampleRate);
    end
    set_param(deserialBlockName,'inputSampleTime',sampleTimeStr);

    types=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);

    complexDataType=types.iscomplex;

    if complexDataType
        set_param(deserialBlockName,'inputSignalType','complex');
    else
        set_param(deserialBlockName,'inputSignalType','real');
    end

    if usesHalfType


        addBlock(this,[],'hdlsllib/HDL Floating Point Operations/Float Typecast',[newSlBlockName,'/castHalfType']);
        addBlock(this,[],'hdlsllib/HDL Floating Point Operations/Float Typecast',[newSlBlockName,'/castToHalfType']);

        add_line(newSlBlockName,'In1/1','castHalfType/1');
        add_line(newSlBlockName,'castHalfType/1',[hC.Name,'/1']);
        add_line(newSlBlockName,[hC.Name,'/1'],'castToHalfType/1');
        add_line(newSlBlockName,'castToHalfType/1','Out1/1');
        Simulink.BlockDiagram.arrangeSystem(newSlBlockName);
    end
end


function newSlBlockName=drawDynamicShiftComp(this,slBlockName,hC)
    gmHandle=add_block('built-in/ArithShift',slpir.PIR2SL.getUniqueName(slBlockName));
    newSlBlockName=getfullname(gmHandle);
    set_param(newSlBlockName,'BitShiftNumberSource','Input port');
    set_param(newSlBlockName,'BitShiftDirection',hC.getShiftMode());
end


function newSlBlockName=drawDataUnbufferComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    set_param(newSlBlockName,'N',sprintf('%d',max(hC.PirInputSignals(1).Type.getDimensions)));
    set_param(newSlBlockName,'factor',sprintf('%d',max(hC.PirOutputSignals(1).Type.getDimensions)));
    hT=hC.PirInputSignals.Type.BaseType;
    if hT.isEnumType
        enumStr=[hT.Name,'.',hT.EnumNames{hT.getDefaultOrdinal+1}];
        set_param(newSlBlockName,'EnumInit',enumStr);
    end
end


function newSlBlockName=drawDemuxComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    set_param(newSlBlockName,'factor',sprintf('%d',max(hC.PirOutputSignals(1).Type.getDimensions)));
end


function newSlBlockName=drawTappedDelayEnabledResettableComp(this,slBlockName,hC)


    if(hC.OrigModelHandle>0)
        newSlBlockName=drawComp(this,slBlockName,hC);
        numDelays=hC.getNumDelays;
        initVal=hC.getInitialValue;
        set_param(newSlBlockName,'vinit',sprintf('%d',initVal));

        set_param(newSlBlockName,'NumDelays',...
        sprintf('%d',numDelays));

        if(hC.getHasExternalSyncReset)
            origBlockHandle=hC.OrigModelHandle;
            extrtype=get_param(origBlockHandle,'ExternalReset');
            set_param(newSlBlockName,'ResetTriggerType',extrtype);
        end
    else
        newSlBlockName=drawComp(this,slBlockName,hC);
        initVal=hC.getInitialValue;
        set_param(newSlBlockName,'vinit',sprintf('%d',initVal));
        delOrder=hC.getDelayOrder;
        if(delOrder)
            set_param(newSlBlockName,'DelayOrder','Oldest');
        else
            set_param(newSlBlockName,'DelayOrder','Newest');
        end
        inclCurr=hC.getIncludeCurrent;
        if(inclCurr)
            set_param(newSlBlockName,'includeCurrent','on');
        else
            set_param(newSlBlockName,'includeCurrent','off');
        end
        if(hC.getHasExternalSyncReset)
            set_param(newSlBlockName,'ResetTriggerType','Level hold');
        end
    end
end


function newSlBlockName=drawCompareToValueComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    if hC.PirOutputSignals(1).Type.is1BitType
        set_param(newSlBlockName,'OutDataTypeStr','boolean');
    else
        set_param(newSlBlockName,'OutDataTypeStr','uint8');
    end

    inputSignal=hC.PirInputSignals(1);
    if hC.hasGeneric

        valueIntStr=hC.getGenericPortValue(0);
        propvalStr=hC.getGenericPortName(0);
        if~IsNameParamArg(slBlockName,propvalStr)
            signed=inputSignal.Type.getLeafType.Signed;
            wordlen=inputSignal.Type.getLeafType.WordLength;
            fraclen=-inputSignal.Type.getLeafType.FractionLength;
            propvalStr=formatGenericVal(valueIntStr,signed,wordlen,fraclen);
        end
        set_param(newSlBlockName,'const',propvalStr)
    end
end


function newSlBlockName=drawLogicComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    set_param(newSlBlockName,'Inputs',sprintf('%d',hC.NumberOfPirInputPorts));
    set_param(newSlBlockName,'AllPortsSameDT','off');
end

function newSlBlockName=drawCompFromSLHandle(this,slBlockName,hC)
    slbh=hC.getSLBlockHandle;
    newSlBlockName=addBlock(this,hC,getfullname(slbh),slBlockName);
    setSampleTime(this,newSlBlockName,hC,'SampleTime');
end


function newSlBlockName=drawDirectLookupTableComp(this,slBlockName,hC)

    if hC.getUseSLHandle
        newSlBlockName=drawCompFromSLHandle(this,slBlockName,hC);
    else
        newSlBlockName=drawDirectLookupTableCompFromPir(this,slBlockName,hC);
    end

end

function newSlBlockName=drawDirectLookupTableCompFromPir(this,slBlockName,hC)

    newSlBlockName=drawComp(this,slBlockName,hC,false,hC.getBlockName,hC.getLibraryName,false);
    dimsStr=int2str(hC.getNumDimensions);
    set_param(newSlBlockName,'NumberOfTableDimensions',dimsStr);
    set_param(newSlBlockName,'Table',formatMatrixVal(this,hC.getTableData,false));
    tableDataType=hC.getTableDataType;
    if strcmpi(tableDataType,'Inherit: Inherit from ''Table data''')
        outSignalType=hC.PirOutputSignals.Type;
        slType=dtconvertpir2sl(outSignalType);
        set_param(newSlBlockName,'TableDataTypeStr',slType.viadialog);
    else
        set_param(newSlBlockName,'TableDataTypeStr',tableDataType);
    end

end

function newSlBlockName=drawLookupTableComp(this,slBlockName,hC)

    if hC.getUseSLHandle
        newSlBlockName=drawCompFromSLHandle(this,slBlockName,hC);
    else
        newSlBlockName=drawLookupTableCompFromPir(this,slBlockName,hC);
    end
end

function newSlBlockName=drawLookupTableCompFromPir(this,slBlockName,hC)

    newSlBlockName=drawMathComp(this,slBlockName,hC,false);
    dimsStr=int2str(hC.getNumDimensions);
    set_param(newSlBlockName,'NumberOfTableDimensions',dimsStr);

    set_param(newSlBlockName,'tableData',formatMatrixVal(this,hC.getTableData,false));



    slobj=get_param(newSlBlockName,'object');
    interpMethods=slobj.getPropAllowedValues('interpMethod');
    interpMeth=hC.getInterpVal;
    if interpMeth==0
        set_param(newSlBlockName,'interpMethod',interpMethods{1});
    else
        set_param(newSlBlockName,'interpMethod',interpMethods{3});
    end


    dims=hC.getNumDimensions;
    bpData=hC.getBpData;
    for i=1:dims
        set_param(newSlBlockName,sprintf('bp%d',i),formatVal(this,bpData{i},false));
    end

    setSampleTime(this,newSlBlockName,hC,'SampleTime');
end



function newSlBlockName=drawConcatComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    numInputs=sprintf('%d',hC.NumberOfPirInputPorts);
    if strcmpi(hC.getBlockName,'built-in/Mux')
        set_param(newSlBlockName,'Inputs',numInputs);
        set_param(newSlBlockName,'DisplayOption','bar');
    else
        set_param(newSlBlockName,'NumInputs',numInputs);
    end
end


function newSlBlockName=drawReshapeComp(this,slBlockName,hC)

    newSlBlockName=slBlockName;

    format=true;
    lib=hC.getLibraryName;
    blk=hC.getBlockName;

    if~isempty(lib)&&~isempty(blk)
        load_system(lib);

        newSlBlockName=addBlock(this,hC,blk,slBlockName);
        pvpairs=setBlockParamsCommon(this,newSlBlockName,hC);

        if isempty(pvpairs)||~iscell(pvpairs)
            return;
        end

        num=length(pvpairs);
        for ii=1:2:num
            propname=pvpairs{ii};
            propval=pvpairs{ii+1};
            if~isempty(propname)&&~isempty(propval)
                if(isnumeric(propval)||isfloat(propval)||islogical(propval))&&format
                    propval=formatVal(this,propval);
                elseif iscell(propval)&&format
                    propval=formatCell(this,propval,false);
                end
                if(strcmp(propname,'OutputDimensions'))
                    newpropval="[";
                    dimsCell=eval(propval);
                    for kk=1:length(dimsCell)
                        newpropval=newpropval+dimsCell(kk)+",";
                    end
                    propval=extractBetween(newpropval,1,strlength(newpropval)-1)+"]";
                end
                set_param(newSlBlockName,propname,propval);
            end
        end
    end
end


function newSlBlockName=drawBitExtractComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);

    rangeStr=sprintf('[%d %d]',hC.getLowerLimit,hC.getUpperLimit);
    if hC.getTreatAsInteger
        modeStr='Treat bit field as an integer';
    else
        modeStr='Preserve fixed-point scaling';
    end

    set_param(newSlBlockName,'bitsToExtract','Range of bits');
    set_param(newSlBlockName,'bitIdxRange',rangeStr);
    set_param(newSlBlockName,'outScalingMode',modeStr);
end

function newSlBlockName=drawBitConcatComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    set_param(newSlBlockName,'numInputs',sprintf('%d',hC.NumberOfPirInputPorts));
end


function newSlBlockName=drawSplitComp(this,slBlockName,hC)
    hT=hC.PirInputSignals(1).Type;
    if hT.isMatrix&&hC.NumberOfPirInputPorts==1
        newSlBlockName=drawSplitCompWithSelectors(this,slBlockName,hC,hT);
    else
        newSlBlockName=drawComp(this,slBlockName,hC);
        set_param(newSlBlockName,'Outputs',sprintf('%d',hC.NumberOfPirOutputPorts));
        set_param(newSlBlockName,'DisplayOption','bar');
    end
end







function newSlBlockName=drawSplitCompWithSelectors(this,slBlockName,hC,hT)

    ssName=this.addBlock(hC,'built-in/SubSystem',slBlockName);


    assert(hC.NumberOfPirInputPorts==1);
    hP=hC.PirInputPorts;
    portName=[ssName,'/',hP.Name];
    [~,portHandle]=this.addBlock([],'built-in/Inport',portName);
    name=get_param(portHandle,'Name');
    name=strrep(name,'/','//');
    if~strcmpi(hP.Name,name)
        hP.Name=name;
    end
    hP.setGMHandle(portHandle);
    inPortName=get_param(hP.getGMHandle,'Name');
    pos=get_param(portHandle,'Position')+[100,0,100,0];



    numCols=hT.Dimensions(2);
    origName=hC.Name;
    for ii=1:numCols
        idxStr=int2str(ii);
        blkName=['ColVec',idxStr];
        selName=[ssName,'/',blkName];

        newSlBlockName=addBlock(this,hC,'built-in/Selector',selName);
        set_param(newSlBlockName,...
        'NumberOfDimensions','2','IndexMode','One-based',...
        'IndexOptionArray',{'Select all','Index vector (dialog)'},...
        'IndexParamArray',{'1',idxStr},'OutputSizeArray',{'1','1'});
        set_param(newSlBlockName,'Position',pos+75*double([0,ii-1,0,ii-1]));

        add_line(ssName,[inPortName,'/1'],[blkName,'/1'],'autorouting','on')

        hP=hC.PirOutputPorts(ii);
        portName=[ssName,'/',hP.Name];

        [~,portHandle]=this.addBlock([],'built-in/Outport',portName);
        name=get_param(portHandle,'Name');
        name=strrep(name,'/','//');
        if~strcmpi(hP.Name,name)
            hP.Name=name;
        end
        hP.setGMHandle(portHandle);
        set_param(portHandle,'Position',pos+75*[1.4,double(ii-1),1.4,double(ii-1)])

        add_line(ssName,[blkName,'/1'],...
        [get_param(portHandle,'Name'),'/1'],'autorouting','on');
    end
    hC.Name=origName;
    newSlBlockName=ssName;
end


function newSlBlockName=drawBitShiftComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    shiftlen=hC.getShiftLength;
    if strcmpi(hC.getOpName,'sll')
        shiftlen=-shiftlen;
    end
    set_param(newSlBlockName,'nBitShiftRight',sprintf('%d',shiftlen));
end


function newSlBlockName=drawRepeatComp(this,slBlockName,hC)
    if isRepeatSupported(this,hC)
        newSlBlockName=drawComp(this,slBlockName,hC);
        set_param(newSlBlockName,'RateOptions','Allow multirate processing');
        set_param(newSlBlockName,'InputProcessing','Elements as channels (sample based)');
    else
        newSlBlockName=drawRepeatAsRateTransition(this,slBlockName,hC);
    end
end


function newSlBlockName=drawRepeatAsRateTransition(this,slBlockName,hC)
    blk='built-in/RateTransition';
    newSlBlockName=addBlock(this,hC,blk,slBlockName);

    factor=hC.getRepetitionCount;
    factorStr=sprintf('1/%d',factor);

    set_param(newSlBlockName,'OutPortSampleTimeOpt','Multiple of input port sample time');
    set_param(newSlBlockName,'OutPortSampleTimeMultiple',factorStr);

    set_param(newSlBlockName,'Integrity','off');
    set_param(newSlBlockName,'Deterministic','off');
end


function isSupported=isRepeatSupported(this,hC)
    isSupported=true;
    hT=hC.PirOutputSignals.Type;




    concurrentTasks='';
    if this.InModelFile
        concurrentTasks=get_param(this.InModelFile,'ConcurrentTasks');
    end
    if~hdlcoderui.isDSTinstalled||hT.BaseType.isEnumType||hT.isRecordType||...
        hT.isArrayOfRecords||hT.getLeafType.isHalfType||strcmpi(concurrentTasks,'on')
        isSupported=false;
    end
end


function newSlBlockName=drawRateTransitionComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    factor=hC.getFactor;
    integrity='on';
    if~hC.getIntegrity
        integrity='off';
    end
    deterministic='on';
    if~hC.getDeterministic
        deterministic='off';
    end
    factorStr=sprintf('%d',factor);
    if hC.getRateup
        factorStr=sprintf('1/%d',factor);
    end

    in=hC.PirInputSignals(1);
    out=hC.PirOutputSignals(1);
    areRatesSynchronous=in.isRateSynchronous(out);
    if areRatesSynchronous
        set_param(newSlBlockName,'OutPortSampleTimeOpt','Multiple of input port sample time');
        set_param(newSlBlockName,'OutPortSampleTimeMultiple',factorStr);
    else
        set_param(newSlBlockName,'OutPortSampleTimeOpt','Specify');
        set_param(newSlBlockName,'OutPortSampleTime','-1');
    end
    set_param(newSlBlockName,'Integrity',integrity);
    set_param(newSlBlockName,'Deterministic',deterministic);
end


function newSlBlockName=drawSampleChangeComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    set_param(newSlBlockName,'ic',formatDoubleVal(hC.getInitialValue));

    set_param(newSlBlockName,'InputProcessing','Elements as channels (sample based)');
    set_param(newSlBlockName,'RateOptions','Allow multirate processing');
end


function newSlBlockName=drawCounterLimitedComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    setSampleTimeCommon(this,newSlBlockName,hC,'tsamp');
end


function newSlBlockName=drawCounterFreeRunningComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    set_param(newSlBlockName,'NumBits',sprintf('%d',hC.PirOutputSignals.Type.Wordlength));
    setSampleTimeCommon(this,newSlBlockName,hC,'tsamp');
end


function newSlBlockName=drawHDLCounterComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    setBoolParameter(newSlBlockName,'CountResetPort',hC.getResetPort);
    setBoolParameter(newSlBlockName,'CountLoadPort',hC.getLoadPort);
    setBoolParameter(newSlBlockName,'CountEnbPort',hC.getEnablePort);
    setBoolParameter(newSlBlockName,'CountDirPort',hC.getDirectionPort);
    setBoolParameter(newSlBlockName,'CountHitOutputPort',hC.getCountHitOutputPort);

    fromEqualsInit=(hC.getCountFrom==hC.getCountInit);
    if fromEqualsInit
        set_param(newSlBlockName,'CountFromType','Initial value');
        set_param(newSlBlockName,'CountFrom',formatVal(this,hC.getCountInit));
    else
        set_param(newSlBlockName,'CountFromType','Specify');
        set_param(newSlBlockName,'CountFrom',formatVal(this,hC.getCountFrom));
    end

    outputSignal=hC.PirOutputSignals;
    signed=outputSignal(1).Type.Signed;
    wordlen=outputSignal(1).Type.WordLength;
    fraclen=-outputSignal(1).Type.FractionLength;
    if signed
        countDataTypeStr='Signed';
    else
        countDataTypeStr='Unsigned';
    end
    set_param(newSlBlockName,'CountDataType',countDataTypeStr);
    set_param(newSlBlockName,'CountWordLen',sprintf('%d',wordlen));
    set_param(newSlBlockName,'CountFracLen',sprintf('%d',fraclen));

    setSampleTimeCommon(this,newSlBlockName,hC,'CountSampTime');
end


function newSlBlockName=drawMinMaxComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    isDSPBlk=hC.getisDSPBlk;
    if~isDSPBlk
        opName=hC.getOpName;
        set_param(newSlBlockName,'Function',opName);
        set_param(newSlBlockName,'Inputs','2');
    else
        warning(message('hdlcoder:engine:MdlGenCompError',hC.Name));
    end
end



function newSlBlockName=drawRelopComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    if hC.getInputSameDT
        val='on';
    else
        val='off';
    end
    set_param(newSlBlockName,'InputSameDT',val);





    hT=hC.PirOutputSignals(1).Type;
    setDataTypeParam(this,newSlBlockName,hT,'OutDataTypeStr',true);
end


function newSlBlockName=drawMathComp(this,slBlockName,hC,format)
    if nargin<4
        format=true;
    end
    newSlBlockName=drawComp(this,slBlockName,hC,false,hC.getBlockName,hC.getLibraryName,format);
    setBoolParameter(newSlBlockName,'SaturateOnIntegerOverflow',strcmpi(hC.getOverflowMode,'Saturate'));
end


function newSlBlockName=drawSumComp(this,slBlockName,hC)
    newSlBlockName=drawMathComp(this,slBlockName,hC);
    accType=hC.AccumType;
    if~isempty(accType)
        setDataTypeParam(this,newSlBlockName,accType,'AccumDataTypeStr');
    end
    set_param(newSlBlockName,'InputSameDT','off');


    set_param(newSlBlockName,'IconShape','Rectangular');





    if isempty(hC.getBlockPath)
        Simulink.suppressDiagnostic(newSlBlockName,'SimulinkFixedPoint:util:Overflowoccurred');
    end

end


function newSlBlockName=drawUnitDelayComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    if hC.getPreserveInitValDimensions
        paramValue=repmat(hC.getInitialValue,1,hC.PirOutputSignals.Type.getDimensions);
        if hC.PirOutputSignals.Type.isColumnVector
            set_param(newSlBlockName,'InitialCondition',['[',num2str(paramValue),']''']);
        else
            set_param(newSlBlockName,'InitialCondition',['[',num2str(paramValue),']']);
        end
    end
end


function newSlBlockName=drawScalarMacComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    outType=hC.PirOutputSignals.Type;
    setDataTypeParam(this,newSlBlockName,outType,'datatype');
    setBoolParameter(newSlBlockName,'DoSatur',strcmpi(hC.getOverflowMode,'Saturate'));
    set_param(newSlBlockName,'RndMeth',hC.getRoundingMode);
    signs=hC.getAdderSign;
    if(strcmp(signs,'+-')==1)
        set_param(newSlBlockName,'Function','c-(a.*b)');
    elseif(strcmp(signs,'-+')==1)
        set_param(newSlBlockName,'Function','(a.*b)-c');
    else
        set_param(newSlBlockName,'Function','c+(a.*b)');
    end
end


function newSlBlockName=drawVectorMacComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    outType=hC.PirOutputSignals.Type;
    setDataTypeParam(this,newSlBlockName,outType,'OutDataTypeStr');
    setBoolParameter(newSlBlockName,'DoSatur',strcmpi(hC.getOverflowMode,'Saturate'));
    set_param(newSlBlockName,'RndMeth',hC.getRoundingMode);
    set_param(newSlBlockName,'initValue',num2str(hC.getInitialValue));
    initValueExternIntern='Dialog';
    if(length(hC.PirInputSignals)>=3)
        initValueExternIntern='Input port';
    end
    set_param(newSlBlockName,'initValueSetting',initValueExternIntern);
end


function newSlBlockName=drawStreamingMacComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    outType=hC.PirOutputSignals(1).Type;
    set_param(newSlBlockName,'opMode',hC.getOpMode);

    switch hC.getOpMode
    case 'Streaming - using Start and End ports'

        setDataTypeParam(this,newSlBlockName,outType,'datatype2');
        set_param(newSlBlockName,'RndMeth2',hC.getRoundingMode);
        set_param(newSlBlockName,'initValue2',num2str(hC.getInitValue));
        set_param(newSlBlockName,'initValueSetting2',hC.getInitValueSetting);

        if hC.getCbox_ValidOut
            Cbox_ValidOut='on';
        else
            Cbox_ValidOut='off';
        end

        if hC.getCbox_EndInAndOut
            Cbox_EndInAndOut='on';
        else
            Cbox_EndInAndOut='off';
        end

        set_param(newSlBlockName,'validOut',Cbox_ValidOut);
        set_param(newSlBlockName,'endInandOut',Cbox_EndInAndOut);
        set_param(newSlBlockName,'startOut',Cbox_ValidOut);

    case 'Streaming - using Number of Samples'

        setDataTypeParam(this,newSlBlockName,outType,'datatype3');
        set_param(newSlBlockName,'RndMeth3',hC.getRoundingMode);
        set_param(newSlBlockName,'initValue3',num2str(hC.getInitValue));
        set_param(newSlBlockName,'initValueSetting3',hC.getInitValueSetting);
        set_param(newSlBlockName,'num_samples',num2str(hC.getNumberOfSamples));
        if hC.getCbox_ValidOut
            Cbox_ValidOut='on';
        else
            Cbox_ValidOut='off';
        end


        if hC.getCbox_CountOut
            Cbox_CountOut='on';
        else
            Cbox_CountOut='off';
        end

        set_param(newSlBlockName,'validOut',Cbox_ValidOut);
        set_param(newSlBlockName,'countOut',Cbox_CountOut);

    end
end


function newSlBlockName=drawGainComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);


    gainVal=hC.getGainValue;
    if isfi(gainVal)
        paramType=sprintf('fixdt(%d, %d, %d)',gainVal.issigned,...
        gainVal.WordLength,gainVal.FractionLength);
        set_param(newSlBlockName,'ParamDataTypeStr',paramType);
    end





    if isHalfType(hC.PirOutputSignals(1).Type.BaseType)
        set_param(newSlBlockName,'OutDataTypeStr','half');
    end

    if hC.hasGeneric
        propvalStr=hC.getGenericPortName(0);
        if isfi(gainVal)&&~IsNameParamArg(slBlockName,propvalStr)

            valueIntStr=hC.getGenericPortValue(0);
            propvalStr=formatGenericVal(valueIntStr,gainVal.issigned,...
            gainVal.WordLength,gainVal.FractionLength);
        end
        set_param(newSlBlockName,'Gain',propvalStr);
    end


    switch(hC.getGainMode)
    case 1,set_param(newSlBlockName,'Multiplication','Element-wise(K.*u)');
    case 2,set_param(newSlBlockName,'Multiplication','Matrix(u*K)');
    case 3,set_param(newSlBlockName,'Multiplication','Matrix(K*u)');
    case 4,set_param(newSlBlockName,'Multiplication','Matrix(K*u) (u vector)');
    end


    setBoolParameter(newSlBlockName,'DoSatur',strcmpi(hC.getOverflowMode,'Saturate'));
end





function newSlBlockName=drawMulComp(this,slBlockName,hC)
    outType=hC.PirOutputSignals.Type.getLeafType;
    if outType.isBooleanType



        slBlockName=drawBlockSubsystem(this,slBlockName,hC);
        newSlBlockName=[slBlockName,'/',hC.Name];
        drawMathComp(this,newSlBlockName,hC);
        subDTCBlkName=addBlock(this,[],'built-in/DataTypeConversion',[slBlockName,'/',hC.Name,'_dtc']);
        set_param(subDTCBlkName,'OutDataTypeStr',getslsignaltype(outType).viadialog);
        add_line(slBlockName,'In1/1',[hC.Name,'/1'],'autorouting','on');
        add_line(slBlockName,'In2/1',[hC.Name,'/2'],'autorouting','on');
        add_line(slBlockName,[hC.Name,'/1'],[hC.Name,'_dtc/1']','autorouting','on');
        add_line(slBlockName,[hC.Name,'_dtc/1']','Out1/1','autorouting','on');
        Simulink.BlockDiagram.arrangeSystem(slBlockName);
    else
        newSlBlockName=drawMathComp(this,slBlockName,hC);
        set_param(newSlBlockName,'InputSameDT','off');
    end
end


function newSlBlockName=drawAbsComp(this,slBlockName,hC)
    newSlBlockName=drawMathComp(this,slBlockName,hC);
end


function newSlBlockName=drawUnaryMinusComp(this,slBlockName,hC)
    newSlBlockName=drawMathComp(this,slBlockName,hC);
end


function newSlBlockName=drawDataConvComp(this,slBlockName,hC)
    newSlBlockName=drawMathComp(this,slBlockName,hC);
    convmode='Stored Integer (SI)';
    if(strcmpi(hC.getConversionMode,'RWV'))
        convmode='Real World Value (RWV)';
    end
    set_param(newSlBlockName,'ConvertRealWorld',convmode);
end


function newSlBlockName=drawBitwiseOpComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    usebitmask=hC.getUseBitMask;
    setBoolParameter(newSlBlockName,'UseBitMask',~isempty(usebitmask)&&usebitmask);

    set_param(newSlBlockName,'NumInputPorts',sprintf('%d',hC.NumberOfPirInputPorts));


    set_param(newSlBlockName,'BitMaskRealWorld','Real World Value');
end


function newSlBlockName=drawBitsetComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    set_param(newSlBlockName,'iBit',formatVal(this,hC.getBitPos-1));
end


function newSlBlockName=drawMuxComp(this,slBlockName,hC)
    newSlBlockName=drawMathComp(this,slBlockName,hC);
    set_param(newSlBlockName,'Inputs',sprintf('%d',hC.NumberOfPirInputPorts-1));
    set_param(newSlBlockName,'InputSameDT','off');

    zeroBased=hC.getZeroBasedIndex;
    setBoolParameter(newSlBlockName,'Zeroidx',isempty(zeroBased)||zeroBased);
end


function newSlBlockName=drawSwitchComp(this,slBlockName,hC)

    compareStr=hC.getCompareStr;
    sw=get_param('built-in/Switch','object');
    criteriaValues=sw.getPropAllowedValues('Criteria');
    if strcmp(compareStr,'>=')
        SLcompareStr=criteriaValues{1};
    elseif strcmp(compareStr,'>')
        SLcompareStr=criteriaValues{2};
    elseif strcmp(compareStr,'~=')
        SLcompareStr=criteriaValues{3};
    end
    hC.setCompareStr(SLcompareStr);

    newSlBlockName=drawMathComp(this,slBlockName,hC);
    set_param(newSlBlockName,'InputSameDT','off');
    hC.setCompareStr(compareStr);
    hT=hC.PirOutputSignals.Type;

    if hT.BaseType.isEnumType
        set_param(newSlBlockName,'OutDataTypeStr',['Enum: ',hT.BaseType.Name]);
    end
end


function newSlBlockName=drawMultiPortSwitchComp(this,slBlockName,hC)
    newSlBlockName=drawMathComp(this,slBlockName,hC);
    set_param(newSlBlockName,'InputSameDT','off');

    numInputs=numel(hC.PirInputPorts)-1;
    if strcmp(hC.getDataPortForDefault,'Additional data port')

        numInputs=numInputs-1;
    end
    numInStr=sprintf('%d',numInputs);
    set_param(newSlBlockName,'Inputs',numInStr);
    set_param(newSlBlockName,'DiagnosticForDefault','None');
    hT=hC.PirOutputSignals.Type;
    if hT.BaseType.isEnumType
        set_param(newSlBlockName,'OutDataTypeStr','Inherit: Inherit via internal rule');
    end
end


function newSlBlockName=drawAssignmentComp(this,slBlockName,hC)
    usesHalfType=hC.PirInputSignals(1).Type.getLeafType.isHalfType;
    idxSigs=3:numel(hC.PirInputSignals);
    idxOptionArray=hC.getIndexOptionArray;
    [sigsToProcess,fiIdx,satDims]=getIdxSignalsToProcess(hC,idxSigs,idxOptionArray);
    atomicParams=true;
    if isempty(sigsToProcess)

        if usesHalfType
            newSlBlockName=drawBlockSubsystem(this,slBlockName,hC);
            addBlock(this,[],'built-in/Assignment',[newSlBlockName,'/',hC.Name]);
        else
            newSlBlockName=drawComp(this,slBlockName,hC,atomicParams);
        end
    else


        newSlBlockName=drawCompWithIdxHandling(this,slBlockName,hC,atomicParams,...
        sigsToProcess,fiIdx,satDims);
    end
    if usesHalfType


        addBlock(this,[],'hdlsllib/HDL Floating Point Operations/Float Typecast',[newSlBlockName,'/castHalfType']);
        addBlock(this,[],'hdlsllib/HDL Floating Point Operations/Float Typecast',[newSlBlockName,'/castHalfType1']);
        addBlock(this,[],'hdlsllib/HDL Floating Point Operations/Float Typecast',[newSlBlockName,'/castToHalfType']);

        add_line(newSlBlockName,'In1/1','castHalfType/1');
        add_line(newSlBlockName,'castHalfType/1',[hC.Name,'/1']);
        add_line(newSlBlockName,'In2/1','castHalfType1/1');
        add_line(newSlBlockName,'castHalfType1/1',[hC.Name,'/2']);
        add_line(newSlBlockName,[hC.Name,'/1'],'castToHalfType/1');
        add_line(newSlBlockName,'castToHalfType/1','Out1/1');
        Simulink.BlockDiagram.arrangeSystem(newSlBlockName);
    end

end


function newSlBlockName=drawSelectorComp(this,slBlockName,hC)
    idxSigs=2:numel(hC.PirInputSignals);
    idxOptionArray=hC.getIndexOptionArray;
    [sigsToProcess,fiIdx,satDims]=getIdxSignalsToProcess(hC,idxSigs,idxOptionArray);
    atomicParams=true;
    if isempty(sigsToProcess)

        newSlBlockName=drawComp(this,slBlockName,hC,atomicParams);
    else


        newSlBlockName=drawCompWithIdxHandling(this,slBlockName,hC,atomicParams,...
        sigsToProcess,fiIdx,satDims);
    end
end


function[sigsToProcess,fiIdx,satDims]=getIdxSignalsToProcess(hC,inputRange,idxOptionArray)











    fiIdx=inputRange(arrayfun(@(pirSig)...
    pirSig.Type.getLeafType.isNumericType&&all(pirSig.Type.getLeafType.WordLength~=[8,16,32]),...
    hC.PirInputSignals(inputRange)));

    if hC.getIsInConditionalBranch&&~isempty(idxOptionArray)
        type=hC.PirInputSignals(1).Type;
        if type.isArrayType
            if type.isRowVector&&numel(idxOptionArray)==1
                idxOptionArray=[idxOptionArray,{''}];
            elseif type.isColumnVector&&numel(idxOptionArray)==1
                idxOptionArray=[{''},idxOptionArray];
            end
        end
        numDims=1:numel(idxOptionArray);

        satDims=numDims(cellfun(@(x)contains(x,'port'),idxOptionArray));
        sigsToProcess=inputRange;
    else
        satDims=[];
        if isempty(fiIdx)
            sigsToProcess=[];
        else
            sigsToProcess=fiIdx;
        end
    end
end


function newSlBlockName=drawCompWithIdxHandling(this,slBlockName,hC,atomicParams,sigsToProcess,fiIdx,satDims)



    slBlockName=drawBlockSubsystem(this,slBlockName,hC);


    newSlBlockName=[slBlockName,'/',hC.Name];


    drawComp(this,newSlBlockName,hC,atomicParams);


    lastBlockPosition=setCompLayout(newSlBlockName);


    drawIdxHandlingComps(this,slBlockName,hC,lastBlockPosition,sigsToProcess,fiIdx,satDims);

    setCompInputConnections(slBlockName,hC,setdiff(1:numel(hC.PirInputSignals),sigsToProcess));

    setCompOutputConnections(slBlockName,hC);
end


function inputDTCBlkName=drawIdxHandlingComps(this,slBlockName,hC,lastBlockPosition,sigsToProcess,fiIdx,satDims)
    move_down=[0,50];
    blkPosition=[lastBlockPosition(1)-50,lastBlockPosition(2)-move_down(2)];

    blkSize=[20,20];
    for ii=sigsToProcess
        blkPositionIter=blkPosition+move_down*ii;
        position=[blkPositionIter,blkPositionIter+blkSize];
        move_right=[50,0,50,0];
        lastPort=['In',int2str(ii),'/1'];

        if~isempty(satDims)

            inputSatBlkName=[slBlockName,'/',hC.Name,'_saturate',int2str(ii)];
            [inputSatBlkName,~]=addBlock(this,[],'simulink/Discontinuities/Saturation',...
            inputSatBlkName);
            type=hC.PirInputSignals(1).Type;
            arrayDims=double(type.Dimensions);
            if type.isArrayType
                if type.isRowVector
                    arrayDims=[arrayDims,1];%#ok<AGROW>
                elseif type.isColumnVector
                    arrayDims=[1,arrayDims];%#ok<AGROW>
                end
            end
            isZeroBased=strcmp(hC.getIndexMode,'Zero-based');
            set_param(inputSatBlkName,'UpperLimit',int2str(arrayDims(satDims(sigsToProcess==ii))-isZeroBased));
            set_param(inputSatBlkName,'LowerLimit',int2str(1-isZeroBased));
            set_param(inputSatBlkName,'Position',position);
            satname=get_param(inputSatBlkName,'name');
            satname=strrep(satname,'/','//');
            satport=[satname,'/1'];
            add_line(slBlockName,lastPort,satport,'autorouting','on');
            lastPort=satport;
            position=position+move_right;
        end
        if~isempty(intersect(ii,fiIdx))

            inputDTCBlkName=[slBlockName,'/',hC.Name,'_to_int',int2str(ii)];
            [inputDTCBlkName,~]=addBlock(this,[],'built-in/DataTypeConversion',...
            inputDTCBlkName);
            set_param(inputDTCBlkName,'OutDataTypeStr','uint32');
            set_param(inputDTCBlkName,'Position',position);
            dtcname=get_param(inputDTCBlkName,'name');
            dtcname=strrep(dtcname,'/','//');
            dtcport=[dtcname,'/1'];
            add_line(slBlockName,lastPort,dtcport,'autorouting','on');
            lastPort=dtcport;
        end
        add_line(slBlockName,lastPort,[hC.Name,'/',int2str(ii)],'autorouting','on');
    end
end


function newSlBlockName=drawPirConstComp(this,slBlockName,hC)
    if hC.PirOutputSignals(1).Type.isArrayType
        dims=hC.PirOutputSignals(1).Type.Dimensions;
    else
        dims=1;
    end

    newSlBlockName=drawComp(this,slBlockName,hC);
    if length(dims)==1&&dims(1)==1
        return;
    end

    if length(dims)==1
        kval=sprintf('repmat(%s, 1, %d)',hC.getValue,dims(1));
    else

        kval=sprintf('repmat(%s, %d, %d)',hC.getValue,dims(1),dims(2));
    end

    set_param(newSlBlockName,'Value',kval);
end


function newSlBlockName=drawConstComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    outputSignal=hC.PirOutputSignals;
    name='Value';

    if hC.hasGeneric

        valueIntStr=hC.getGenericPortValue(0);
        propvalStr=hC.getGenericPortName(0);
        if~IsNameParamArg(slBlockName,propvalStr)
            signed=outputSignal.Type.getLeafType.Signed;
            wordlen=outputSignal.Type.getLeafType.WordLength;
            fraclen=-outputSignal.Type.getLeafType.FractionLength;
            propvalStr=formatGenericVal(valueIntStr,signed,wordlen,fraclen);
            paramType=sprintf('fixdt(%d, %d, %d)',signed,wordlen,fraclen);
            set_param(newSlBlockName,'OutDataTypeStr',paramType);
        end
    else
        value=hC.getConstantValue;



        useComplexCast=false;


        if(isreal(value))
            tp=hC.PirOutputSignals(1).Type;
            if(tp.isArrayType)
                tp=tp.BaseType;
            end

            if(tp.isComplexType())
                value=complex(value);
                useComplexCast=true;
            end
        end

        outType=outputSignal.Type;
        if isstruct(value)||(outType.isRecordType||outType.isArrayOfRecords)
            propvalStr=hC.getConstBusName;
            set_param(newSlBlockName,'OutDataTypeStr',hC.getConstBusType);
        else




            if(isfi(value)&&isreal(value))
                propvalStr=num2str(value.Value,value.FractionLength);
            else
                propvalStr=formatVal(this,value);
            end
        end


        if(isscalar(value)&&outputSignal.Type.isArrayType)
            vectorSize=pirelab.getVectorTypeInfo(outputSignal,true);


            vectorStr=['[',int2str(vectorSize),']'];

            if useComplexCast
                propvalStr=['complex( repmat(',propvalStr,',',vectorStr,') )'];
            else
                propvalStr=['repmat(',propvalStr,',',vectorStr,')'];
            end
        end
        if isSLEnumType(class(value))
            set_param(newSlBlockName,'OutDataTypeStr',['Enum: ',class(value)]);
        end
    end
    set_param(newSlBlockName,name,propvalStr);
    setSampleTimeCommon(this,newSlBlockName,hC);
end


function newSlBlockName=drawSaturationComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC,true);
end


function newSlBlockName=drawHitCrossComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);

    hcDirection=hC.getHcDirectionMode();
    if hcDirection==0
        set_param(newSlBlockName,'HitCrossingDirection','rising');
    elseif hcDirection==1
        set_param(newSlBlockName,'HitCrossingDirection','falling');
    else
        set_param(newSlBlockName,'HitCrossingDirection','either');
    end
end


function newSlBlockName=drawBacklashComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);



    backlashWidth=hC.getBacklashWidth();
    set_param(newSlBlockName,'BacklashWidth',formatVal(this,backlashWidth.*2));
end


function newSlBlockName=drawMathFuncComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    set_param(newSlBlockName,'Operator',hC.getFunctionName());
end


function newSlBlockName=drawTransposeComp(this,slBlockName,hC)
    [~,slbh]=addBlock(this,hC,'built-in/Math',slBlockName,true);
    newSlBlockName=getfullname(slbh);

    set_param(slbh,'Function','transpose');
end


function newSlBlockName=drawHermitianComp(this,slBlockName,hC)
    mode='Off';
    [~,slbh]=addBlock(this,hC,'built-in/Math',slBlockName,true);
    newSlBlockName=getfullname(slbh);

    set_param(slbh,'Function','hermitian');
    if(hC.getSaturationMode())
        mode='On';
    end
    set_param(slbh,'SaturateOnIntegerOverflow',mode);


    if hC.PirOutputSignals.Type.BaseType.isComplexType
        set_param(slbh,'OutputSignalType','complex');
    end
end


function newSlBlockName=drawUnitDelayEnabledComp(this,slBlockName,hC)
    if hC.Owner.isSLResettableSubsys
        newSlBlockName=drawUnitDelayNonResettableComp(this,slBlockName,hC);
    else
        newSlBlockName=drawComp(this,slBlockName,hC);
    end


    setSampleTime(this,newSlBlockName,hC,'tsamp');



    if~isempty(hC.getInitialValue)
        set_param(newSlBlockName,'vinit',formatVal(this,hC.getInitialValue));
    end
end


function newSlBlockName=drawUnitDelayEnabledResettableComp(this,slBlockName,hC)
    initVal=hC.getInitialValue;
    outType=hC.PirOutputSignals.Type;
    outLeafType=outType.getLeafType;
    if outType.BaseType.isEnumType


        newSlBlockName=drawBlockSubsystem(this,slBlockName,hC);
        if hC.Owner.isSLResettableSubsys
            unitDelayBlockName=drawUnitDelayNonResettableComp(this,[newSlBlockName,'/',hC.Name],hC);
        else
            unitDelayBlockName=drawComp(this,[newSlBlockName,'/',hC.Name],hC);
        end

        initVal=repmat(outLeafType.EnumValues(1),1,outType.Dimensions);
        subDTC1_BlkName=addBlock(this,[],'built-in/DataTypeConversion',[newSlBlockName,'/',hC.Name,'_dtc1']);
        add_line(newSlBlockName,'In1/1',[hC.Name,'_dtc1/1'],'autorouting','on');
        add_line(newSlBlockName,'In2/1',[hC.Name,'/2'],'autorouting','on');
        add_line(newSlBlockName,[hC.Name,'_dtc1/1'],[hC.Name,'/1'],'autorouting','on');
        set_param(subDTC1_BlkName,'OutDataTypeStr',class(initVal));
        subDTC2_BlkName=addBlock(this,[],'built-in/DataTypeConversion',[newSlBlockName,'/',hC.Name,'_dtc2']);
        add_line(newSlBlockName,[hC.Name,'/1'],[hC.Name,'_dtc2/1'],'autorouting','on');
        add_line(newSlBlockName,[hC.Name,'_dtc2/1'],'Out1/1','autorouting','on');
        set_param(subDTC2_BlkName,'OutDataTypeStr',['Enum: ',getslsignaltype(outLeafType).viadialog]);
    else
        if hC.Owner.isSLResettableSubsys
            newSlBlockName=drawUnitDelayNonResettableComp(this,slBlockName,hC);
            unitDelayBlockName=newSlBlockName;
        else
            newSlBlockName=drawComp(this,slBlockName,hC);
            unitDelayBlockName=newSlBlockName;
        end

    end

    if~isempty(initVal)
        if(hC.isSynchronousDelay)
            initValStr='InitialCondition';
        else
            initValStr='vinit';
        end
        set_param(unitDelayBlockName,initValStr,formatVal(this,initVal));
    end
end


function newSlBlockName=drawUnitDelayNonResettableComp(this,slBlockName,hC)
    lib=hC.getLibraryName;
    if~isempty(lib)
        load_system(lib);

        if hC.getHasExternalEnable
            if hC.isSynchronousDelay
                blk='hdlsllib/Discrete/Unit Delay Enabled Synchronous';
            else
                blk='simulink/Additional Math & Discrete/Additional Discrete/Unit Delay Enabled';
            end
        else
            blk='built-in/UnitDelay';
        end
        newSlBlockName=addBlock(this,hC,blk,slBlockName);
        setParams(this,newSlBlockName,hC,false);
    end
end


function newSlBlockName=drawIntDelayEnabledResettableComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);

    if hC.getHasExternalEnable
        set_param(newSlBlockName,'ShowEnablePort','on');
    end

    if hC.getHasExternalSyncReset
        if hC.Owner.isSLResettableSubsys
            set_param(newSlBlockName,'ExternalReset','None');
        elseif hC.Owner.hasSLHWFriendlySemantics||hC.Owner.getWithinHWFriendlyHierarchy
            set_param(newSlBlockName,'ExternalReset','Level hold');
        else
            set_param(newSlBlockName,'ExternalReset','Level');
        end
    end

    if~isempty(hC.getInitialValue)
        set_param(newSlBlockName,'vinit',formatVal(this,hC.getInitialValue));
    end
end


function newSlBlockName=drawTappedDelayComp(this,slBlockName,hC)
    initVal=hC.getInitialValue();
    hT=hC.PirInputSignals(1).Type;
    if hT.BaseType.isEnumType


        newSlBlockName=drawBlockSubsystem(this,slBlockName,hC);
        tappedDelayBlockName=drawComp(this,[newSlBlockName,'/',hC.Name],hC);

        initVal=hT.EnumValues(1);
        subDTC1_BlkName=addBlock(this,[],'built-in/DataTypeConversion',[newSlBlockName,'/',hC.Name,'_dtc1']);
        add_line(newSlBlockName,'In1/1',[hC.Name,'_dtc1/1'],'autorouting','on');
        add_line(newSlBlockName,[hC.Name,'_dtc1/1'],[hC.Name,'/1'],'autorouting','on');
        set_param(subDTC1_BlkName,'OutDataTypeStr',class(initVal));

        subDTC2_BlkName=addBlock(this,[],'built-in/DataTypeConversion',[newSlBlockName,'/',hC.Name,'_dtc2']);
        add_line(newSlBlockName,[hC.Name,'/1'],[hC.Name,'_dtc2/1'],'autorouting','on');
        add_line(newSlBlockName,[hC.Name,'_dtc2/1'],'Out1/1','autorouting','on');
        set_param(subDTC2_BlkName,'OutDataTypeStr',['Enum: ',getslsignaltype(hT).viadialog]);
    else
        newSlBlockName=drawComp(this,slBlockName,hC);
        tappedDelayBlockName=newSlBlockName;
    end





    if~isempty(initVal)
        if~isreal(initVal)

            initVal_dbl=double(initVal);
            initVal_str=[coder.internal.tools.TML.tostr(real(initVal_dbl)),...
            ' + j*',coder.internal.tools.TML.tostr(imag(initVal_dbl))];
            set_param(tappedDelayBlockName,'vinit',initVal_str);
        else
            set_param(tappedDelayBlockName,'vinit',formatDoubleVal(initVal));
        end
    end

    setBoolParameter(tappedDelayBlockName,'includeCurrent',hC.getIncludeCurrent);

    if hC.getDelayOrder
        set_param(tappedDelayBlockName,'DelayOrder','Oldest');
    else
        set_param(tappedDelayBlockName,'DelayOrder','Newest');
    end
end


function newSlBlockName=drawIntegerDelayComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC,false);

    if~(hC.Owner.hasEnabledInstances||hC.Owner.hasTriggeredInstances)


        st=hC.PirOutputSignals(1).SimulinkRate;
        if~isinf(st)&&(st~=0)
            set_param(newSlBlockName,'samptime',sprintf('%16.15g',st));
        end
    end




    icVal=hC.getInitialValue;
    if~isempty(icVal)
        if hC.PirInputSignals(1).Type.getLeafType.isEnumType
            inType=hC.PirInputSignals(1).Type.getLeafType;
            if ischar(class(icVal))&&strcmp(class(icVal),inType.Name)
                fmtIC=sprintf('%s.%s',inType.Name,char(icVal));
            else

                fmtIC=sprintf('%s.%s',inType.name,inType.EnumNames{icVal+1});
            end
        else
            if~isreal(icVal)
                icVal_dbl=double(icVal);


                fmtIC_real=formatDoubleValForDelay(real(icVal_dbl),...
                pirelab.getVectorTypeInfo(hC.PirInputSignals(1)),hC.getNumDelays);
                fmtIC_imag=formatDoubleValForDelay(imag(icVal_dbl),...
                pirelab.getVectorTypeInfo(hC.PirInputSignals(1)),hC.getNumDelays);
                fmtIC=[fmtIC_real,' + j*',fmtIC_imag];
            else

                if hC.getPreserveInitValDimensions


                    delayOutputSignalType=hC.PirOutputSignals.Type;
                    if delayOutputSignalType.isArrayType&&delayOutputSignalType.isRowVector
                        dims=[hC.getNumDelays,delayOutputSignalType.getDimensions];
                    else
                        dims=[delayOutputSignalType.getDimensions,hC.getNumDelays];
                    end
                    icVal=repmat(icVal,dims);
                end
                fmtIC=formatDoubleValForDelay(double(icVal),...
                pirelab.getVectorTypeInfo(hC.PirInputSignals(1)),hC.getNumDelays);
            end
        end
        set_param(newSlBlockName,'vinit',fmtIC);
    end

    if hC.getIsPipelineReg
        if hC.getDoNotDistribute
            set_param(newSlBlockName,'BackgroundColor','green');
        else
            set_param(newSlBlockName,'BackgroundColor','orange');
        end
    end
end


function newSlBlockName=drawEMLComp(this,slBlockName,hC)
    newSlBlockName=slBlockName;
    if hC.Synthetic
        drawEMLBlock(this,slBlockName,hC);
    else
        drawSLBlock(this,slBlockName,hC);
    end
end


function newSlBlockName=drawTerminatorComp(this,slBlockName,hC)
    newSlBlockName=addBlock(this,hC,'built-in/Terminator',slBlockName);
end







function newPath=drawAnnotationComp(this,hC,slBlockName)
    newPath=slBlockName;
    origPos=get_param(hC.SimulinkHandle,'Position');
    origTxt=get_param(hC.SimulinkHandle,'Name');
    strpos=strfind(slBlockName,origTxt);
    if~isempty(strpos)
        newPath=slpir.PIR2SL.getUniqueName([slBlockName(1:strpos(end)-1),hC.RefNum]);
        try
            h=add_block('built-in/Note',newPath,'Position',[origPos(1),0,0,origPos(2)]);
            set_param(h,'Name',origTxt);
            annoParams={...
            'FontName','FontSize','FontWeight','FontAngle',...
            'ForegroundColor','BackgroundColor','DropShadow',...
            'Description','HiliteAncestors','Position',...
            };


            for ii=1:numel(annoParams)
                set_param(h,annoParams{ii},...
                get_param(hC.SimulinkHandle,annoParams{ii}));
            end
        catch
            return;
        end
    end
end


function newSlBlockName=drawAssertionComp(this,slBlockName,hC)
    newSlBlockName=slBlockName;
    lib=hC.getLibraryName;
    blk=hC.getBlockName;

    if~isempty(lib)&&~isempty(blk)
        load_system(lib);
        newSlBlockName=addBlock(this,hC,blk,slBlockName);
        pvpairs=setBlockParamsCommon(this,slBlockName,hC);
        if isempty(pvpairs)||~iscell(pvpairs)
            return;
        end

        num=length(pvpairs);
        hdlset_param(slBlockName,'Architecture','Assertion');
        for ii=1:2:num
            propname=pvpairs{ii};
            propval=pvpairs{ii+1};
            if~isempty(propname)&&~isempty(propval)
                if isnumeric(propval)||isfloat(propval)||islogical(propval)
                    propval=formatVal(this,propval);
                elseif iscell(propval)
                    propval=formatCell(this,propval,false);
                end
                if strcmp(propname,'Label')
                    hdlset_param(slBlockName,propname,propval);
                else
                    set_param(slBlockName,propname,propval);
                end
            end
        end
    end
end


function drawCtxRefComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);
    set_param(newSlBlockName,'ModelName',hC.PirCtx.GeneratedModelName);
    if hC.getNumGeneric()>0
        connectCompGenericPorts(hC,newSlBlockName);
    end
end


function newSlBlockName=drawBusCreatorComp(this,slBlockName,hC)

    newSlBlockName=drawComp(this,slBlockName,hC);
    numinputs=length(hC.PirInputPorts);
    set_param(newSlBlockName,'Inputs',int2str(numinputs));




    if hC.OrigModelHandle>0
        if strcmp(get_param(hC.OrigModelHandle,'BlockType'),'BusCreator')
            set_param(newSlBlockName,'InheritFromInputs',get_param(hC.OrigModelHandle,'InheritFromInputs'));
        end
    end
end


function newSlBlockName=drawBusSelectorComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC,false);
    outs=hC.PirOutputSignals;

    if hC.getOutputIsBus
        set_param(newSlBlockName,'OutputAsBus','on');
        portHandles=get_param(newSlBlockName,'PortHandles');


        for i=1:length(outs)
            set_param(portHandles.Outport(i),'Name',outs(i).Name);
        end
    end
end


function newSlBlockName=drawRecipComp(this,slBlockName,hC)
    if hC.getIterNum>0
        newSlBlockName=slpir.PIR2SL.getUniqueName(slBlockName);
        this.drawReciCompNewtonImp(newSlBlockName,hC);
    else

        newSlBlockName=drawComp(this,slBlockName,hC,false);
        set_param(newSlBlockName,'Operator','reciprocal');


        if(hC.OrigModelHandle>0)
            val=get_param(hC.OrigModelHandle,'OutDataTypeStr');
            set_param(newSlBlockName,'OutDataTypeStr',val);
        end
    end
end


function newSlBlockName=drawCplxConjugateComp(this,slBlockName,hC)
    [~,slbh]=addBlock(this,hC,'built-in/Math',slBlockName,true);
    set_param(slbh,'Function','conj');
    newSlBlockName=getfullname(slbh);
end


function newSlBlockName=drawIndexComp(this,slBlockName,hC)
    [~,slbh]=addBlock(this,hC,'built-in/Selector',slBlockName,true);
    set_param(slbh,'Indices',num2str(hC.getIndex()+1));
    set_param(slbh,'InputPortWidth',num2str(hC.PirInputSignals.Type.Dimensions));
    newSlBlockName=getfullname(slbh);
end


function newSlBlockName=drawSignumComp(this,slBlockName,hC)
    inType=hC.PirInputSignals(1).Type.getLeafType;
    outType=hC.PirOutputSignals(1).Type.getLeafType;
    if~inType.isFloatType&&~outType.isFloatType&&...
        inType.WordLength~=outType.WordLength


        newSlBlockName=drawBlockSubsystem(this,slBlockName,hC);
        addBlock(this,[],'built-in/Signum',[newSlBlockName,'/',hC.Name]);
        subDTCBlkName=addBlock(this,[],'built-in/DataTypeConversion',[newSlBlockName,'/',hC.Name,'_dtc']);
        add_line(newSlBlockName,'In1/1',[hC.Name,'/1'],'autorouting','on');
        add_line(newSlBlockName,[hC.Name,'/1'],[hC.Name,'_dtc/1'],'autorouting','on');
        add_line(newSlBlockName,[hC.Name,'_dtc/1'],'Out1/1','autorouting','on');
        set_param(subDTCBlkName,'OutDataTypeStr',getslsignaltype(outType).viadialog);
        Simulink.BlockDiagram.arrangeSystem(newSlBlockName);
    else
        newSlBlockName=drawComp(this,slBlockName,hC);
    end
end


function newSlBlockName=drawNFPSqrtComp(this,slBlockName,hC)
    newSlBlockName=drawComp(this,slBlockName,hC);


    slbh=hC.OrigModelHandle;

    if(slbh>0)
        intermResDataType=get_param(slbh,'IntermediateResultsDataTypeStr');
        set_param(newSlBlockName,'IntermediateResultsDataTypeStr',intermResDataType);
    end
end



function drawSyntheticRamComp(this,slBlockName,hC,syntheticRamType)


    load_system('hdlsllib');

    newSlBlockName=addBlock(this,hC,...
    ['hdlsllib/HDL RAMs/',syntheticRamType,' System'],slBlockName);


    iv=hC.getSyntheticRamIV;
    if isempty(iv)
        iv='0';
    end

    if isnumeric(iv)


        firstelem=iv(1);

        if all(iv==firstelem)
            iv=firstelem;
        end

        iv=mat2str(iv);
    end

    set_param(newSlBlockName,'RAMInitialValue',iv);

    if strcmp(syntheticRamType,'Single Port RAM')||...
        strcmp(syntheticRamType,'Dual Port RAM')

        wrOutputValue='Old data';
        if hC.syntheticRamIsWriteBeforeRead
            wrOutputValue='New data';
        end
        set_param(newSlBlockName,'WriteOutputValue',wrOutputValue);
    end

end


function setPortParam(trgBlockName,~)
    if strcmp(get_param(trgBlockName,'BlockType'),'BusSelector')
        set_param(trgBlockName,'OutputSignals',...
        get_param(trgBlockName,'OutputSignals'));
    end
end


function newSlBlockName=drawSLBlock(this,slBlockName,hC)

    newSlBlockName=slBlockName;
    if hC.Synthetic
        return;
    end
    not_MsgViewer=hC.isAnnotation&&~isa(get_param(hC.SimulinkHandle,'Object'),'Simulink.MessageViewer');
    if hC.isAnnotation&&hC.NumberOfPirInputPorts==0&&hC.NumberOfPirOutputPorts==0&&not_MsgViewer
        newSlBlockName=drawAnnotationComp(this,hC,slBlockName);
    else
        slHandle=hC.SimulinkHandle;
        newSlBlockName=getfullname(slHandle);
        if strcmpi(this.SLEngineDebug,'off')
            [~,newslHandle]=addBlock(this,hC,getfullname(slHandle),slBlockName);
        else
            [~,newslHandle]=addBlock(this,hC,slHandle,slBlockName);
        end
        setProperties(this,hC,newslHandle);
        if~strcmp(get_param(slHandle,'Type'),'annotation')
            setPortParam(slBlockName,slHandle);
        end
    end
end


function newSlBlockName=drawPirSubsystem(this,slBlockName,hC)
    hRefNtwk=hC.ReferenceNetwork;
    [newSlBlockName,slHandle]=addBlock(this,hC,'built-in/SubSystem',slBlockName);
    setProperties(this,hC,slHandle);

    addSubSystemPorts(this,newSlBlockName,hRefNtwk);
end



















function retval=formatDoubleVal(val)
    if~isscalar(val)
        sz=size(val);
        retval='[';
        for i=1:sz(1)
            for j=1:sz(2)
                retval=[retval,sprintf(' %g',double(val(i,j)))];%#ok<AGROW>
            end
        end
        retval=[retval,']'];

        if ndims(val)>1&&size(val,2)==1
            retval=[retval,'.'''];
        end
    else
        retval=sprintf('%g',double(val));
    end
end


function retval=formatDoubleValForDelay(val,uDim,dLen)
    sz=size(val);
    if prod(uDim)==max(uDim)&&...
        dLen>1&&sz(2)~=dLen&&length(val)==prod(uDim)*dLen




        retval='[';
        icval=reshape(val,[uDim,dLen]);
        for i=1:uDim
            for j=1:dLen
                retval=[retval,printInDouble(icval(i,j))];%#ok<AGROW>
            end
            retval=[retval,' ;'];%#ok<AGROW>
        end
        retval=[retval,']'];
    else
        retval=coder.internal.tools.TML.tostr(val);
    end
end

function retval=printInDouble(val)
    if(isreal(val))
        retval=sprintf(' %g',double(val));
    else
        retval=sprintf(' %g+%gi',real(double(val)),imag(double(val)));
    end
end



function retval=formatGenericVal(valueIntStr,signed,wordlen,fraclen)

    retval=sprintf('fi(0,%d,%d,%d,''int'',%s)',signed,wordlen,fraclen,convertGenericValToStr(valueIntStr));
end

function valInStr=convertGenericValToStr(val)
    if isscalar(val)
        valInStr=num2str(val);
    else

        numElems=numel(val);
        valElemStrs=cell(1,numElems);

        for ii=1:numElems
            valElemStrs{ii}=convertGenericValToStr(val(ii));
        end

        if isrow(val)
            joinStr=', ';
        else
            joinStr='; ';
        end

        valInStr=['[',strjoin(valElemStrs,joinStr),']'];
    end
end


function isValid=setDataTypeParam(this,slBlock,hType,paramName,forceFixdtType)
    if nargin<4
        paramName='OutDataTypeStr';
    end

    if nargin<5
        forceFixdtType=false;
    end

    sltype=computeDataType(this,hType,forceFixdtType);
    isValid=outputDataTypeValid(slBlock,paramName,sltype.viadialog);
    if isValid
        set_param(slBlock,paramName,sltype.viadialog);

    end
end


function isValid=outputDataTypeValid(slBlock,paramName,typeStr)
    isValid=true;
    if strncmp(typeStr,'fixdt',5)

        return;
    end

    if strcmp(typeStr,'half')

        return;
    end
    slObj=get_param(slBlock,'Object');
    supportedValues=slObj.getPropAllowedValues(paramName);
    if~any(strcmp(supportedValues,typeStr))
        isValid=false;
    end
end


function connectCompGenericPorts(hC,blkName)
    mdlrefNumGenericPorts=hC.getNumGeneric();
    slbh=hC.SimulinkHandle;
    if mdlrefNumGenericPorts>0



        paramArgVals=get_param(slbh,'ParameterArgumentValues');
        paramNames=fields(paramArgVals);
        paramValues=struct2cell(paramArgVals);
        maskValues=get_param(slbh,'MaskValues');

        if~isempty(maskValues)
            maskNames=get_param(slbh,'MaskNames');
            for kk=1:length(maskValues)
                for jj=1:length(paramValues)
                    if strcmp(maskNames{kk},paramValues{jj})==1
                        paramValues{jj}=maskValues{kk};
                        break;
                    end
                end
            end
        end
        blkParamVals={};
        if~isempty(paramArgVals)
            for itr=0:(mdlrefNumGenericPorts-1)
                genericName=hC.getGenericPortName(itr);
                for kk=1:length(paramNames)
                    paramName=paramNames{kk};

                    if strcmpi(paramName,genericName)==1
                        blkParamVals{end+1}=paramValues{kk};%#ok<AGROW>
                        continue;
                    end
                end
            end
            blkParamValStr=strjoin(blkParamVals,',');
            set_param(blkName,'ParameterArgumentValues',blkParamValStr);
        end
    end
end


function paramStrPresent=IsNameParamArg(slBlockName,paramStr)

    paramStrPresent=false;
    slbh=get_param(slBlockName,'Handle');
    if slbh>0
        parent=get_param(slbh,'Parent');
        parentslbh=get_param(parent,'Handle');
        while parentslbh>0&&~strcmpi(get_param(parentslbh,'Type'),'block_diagram')
            parent=get_param(parentslbh,'Parent');
            parentslbh=0;
            if~isempty(parent)
                parentslbh=get_param(parent,'Handle');
            end
        end
    end
    if parentslbh>0
        paramArgNames=get_param(parentslbh,'ParameterArgumentNames');
        if~isempty(paramArgNames)
            paramNames=regexp(paramArgNames,',','split');
            for itr=1:length(paramNames)
                paramName=paramNames{itr};
                if strcmp(paramName,paramStr)
                    paramStrPresent=true;
                    break;
                end
            end
        end
    end
end

function drawSLBlockForNIC(this,tgtParentPath,hC,slBlockName)%#ok<INUSL>

    latency=hC.getAccumOutputLatency;

    if latency<=0

        addBlockFromTag(this,hC,slBlockName);
    else




        slSubsysName=slBlockName;
        slSubsysName=drawBlockSubsystem(this,slSubsysName,hC);


        slBlockName=[slSubsysName,'/',hC.Name,''];
        modelHandle=addBlockFromTag(this,hC,slBlockName);


        numPorts=get_param(modelHandle,'Ports');
        numInports=numPorts(1);


        for ii=1:length(hC.PirInputPorts)
            if ii<=numInports

                oport=sprintf('In%i/1',ii);
                iport=sprintf('%s/%i',hC.Name,ii);
                add_line(slSubsysName,oport,iport,'autorouting','on');
            else

                oport=sprintf('In%i/1',ii);
                terminatorBlockName=[slSubsysName,'/Terminator'];
                [~,hTerminatorBlock]=addBlock(this,[],'built-in/Terminator',terminatorBlockName);
                newTerminatorBlockName=get_param(hTerminatorBlock,'Name');
                add_line(slSubsysName,oport,[newTerminatorBlockName,'/1'],'autorouting','on');
            end
        end


        lastBlockPosition=[260,40];
        drawOutputDelayComp_inputDelay(this,slSubsysName,hC,lastBlockPosition,latency);

        Simulink.BlockDiagram.arrangeSystem(slSubsysName);
    end

end

function modelHandle=addBlockFromTag(this,hC,slBlockName)




    mdlGenTag=hC.getModelGenForNICTag;

    if mdlGenTag.getUseLibBlock
        sourceBlockPath=mdlGenTag.getLibBlockName;
        [uniqueBlkName,~]=addBlock(this,hC,sourceBlockPath,slBlockName);


        params=mdlGenTag.getLibBlockParameters;
        set_param(uniqueBlkName,params{:});


        modelHandle=get_param(uniqueBlkName,"Handle");
    else


        originalBlkPath=getfullname(hC.origModelHandle);
        addBlock(this,hC,originalBlkPath,slBlockName);
        modelHandle=hC.origModelHandle;
    end

end










