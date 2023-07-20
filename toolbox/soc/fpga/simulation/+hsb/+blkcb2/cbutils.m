function varargout=cbutils(varargin)
    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end

function MaskParamCb(paramName,blkH,cbH)%#ok<*DEFNU>

    cbVal=get_param(blkH,paramName);
    vis=get_param(blkH,'MaskVisibilities');
    ens=get_param(blkH,'MaskEnables');
    pnames=get_param(blkH,'MaskNames');

    idxMap=containers.Map;
    for ii=1:length(pnames)
        idxMap(pnames{ii})=ii;
    end

    [vis,ens]=cbH(blkH,cbVal,vis,ens,idxMap);

    set_param(blkH,...
    'MaskVisibilities',vis,...
    'MaskEnables',ens...
    );

end


function blkPath=GetBlkPath(blkH)
    blkPath=[get(blkH,'Path'),'/',get(blkH,'Name')];
end
function p=GetDialogParams(blkH,varargin)
    if numel(varargin)>=1
        action=varargin{1};
    else
        action='null';
    end
    switch action
    case 'forceSync'







        paramToUseForSync=varargin{2};
        syncval=get_param(blkH,paramToUseForSync);

        sw=warning('off','Simulink:Commands:SetParamLinkChangeWarn');
        tmp=onCleanup(@()warning(sw));
        set_param(blkH,paramToUseForSync,syncval);
    otherwise



    end

    vars=get_param(blkH,'MaskWSVariables');
    p=cell2struct({vars.Value},{vars.Name},2);







end
function p=GetDialogParamsInChild(parentBlkH,childBlkH)
    dpnames=fieldnames(get_param(childBlkH,'DialogParameters'));
    dpstrvalues=cellfun(@(x)(get_param(childBlkH,x)),dpnames,'UniformOutput',false);
    dpvalues={};
    for v=dpstrvalues'
        try
            val=slResolve(v{1},parentBlkH);
        catch ME %#ok<NASGU>
            val=v{1};
        end
        dpvalues{end+1}=val;%#ok<AGROW>
    end
    p=cell2struct(dpvalues,dpnames',2);
end
...
...
...
...
...
...
...
...
...
function outVal=TryEval(inVal)
    if~isnumeric(inVal)
        try
            outVal=evalin('base',inVal);
        catch ME %#ok<NASGU>
            outVal=inVal;
        end
    else
        outVal=inVal;
    end
end
function CreateBusInBase(name,description,sigs)

    bus=Simulink.Bus;
    bus.Description=description;

    for ii=1:4:numel(sigs)-1
        be=Simulink.BusElement;
        be.Name=sigs{ii};
        be.DataType=sigs{ii+1};
        be.Dimensions=sigs{ii+2};
        be.Description=sigs{ii+3};
        bus.Elements(end+1)=be;
    end

    assignin('base',name,bus);

end
function SetDerivedMaskParams(blkH,dp)
    pnames=fieldnames(dp);
    pv=cell(1,length(pnames)*2);
    ii=0;
    for pname=pnames'
        ii=ii+1;pv{ii}=pname{1};
        pvalue=dp.(pname{1});
        if isnumeric(pvalue)
            pvalueStr=mat2str(pvalue,16);
        elseif isa(pvalue,'Simulink.NumericType')
            pvalueStr=pvalue.tostring();
        elseif isa(pvalue,'Simulink.AliasType')
            pvalueStr=pvalue.BaseType;
        else
            pvalueStr=pvalue;
        end
        ii=ii+1;pv{ii}=pvalueStr;
    end
    if~isempty(pv)

        sw=warning('off','Simulink:Commands:SetParamLinkChangeWarn');
        tmp=onCleanup(@()warning(sw));
        set_param(blkH,pv{:});
    end
end
function dst=CopyDerivedMaskParams(src,dst)
    pnames=fieldnames(src);
    for pname=pnames'
        if isfield(dst,pname{1})
            dst.(pname{1})=src.(pname{1});
        end
    end
end
function tf=IsIntegerValue(num)







    tf=(abs(round(num)-num)<=eps(num));
end

function SetCSParam(sysH,csPV)
    cs=getActiveConfigSet(sysH);
    for i=1:2:numel(csPV)




        codertarget.fpgadesign.internal.fpgaDesignCallback(cs,'manualValueChangeCb',csPV{i},csPV{i+1});
    end
end
function csval=GetCSParam(sysH,csparam)
    cs=getActiveConfigSet(sysH);
    csval=hsb.blkcb2.cbutils('TryEval',codertarget.data.getParameterValue(cs,['FPGADesign.',csparam]));
end
function[blkDP,blkP]=GetConfigsetValues(blkH,useConfigSetVals,blkP,pNamesInCS,pNamesInBlk)
    if hsb.blkcb2.cbutils('IsLibContext',blkH),return;end

    blkDP=struct();
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    badTargetWarn=codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockGetParam',blkPath);

    getCSVals=~badTargetWarn&&strcmp(useConfigSetVals,'on');

    if getCSVals
        try
            sysH=bdroot(blkH);
            cs=getActiveConfigSet(sysH);
            FPGADesign=codertarget.data.getParameterValue(cs,'FPGADesign');
            nn=0;
            for pcsName=pNamesInCS
                nn=nn+1;
                pNameInBlk=pNamesInBlk{nn};
                if getCSVals

                    csval=hsb.blkcb2.cbutils('TryEval',FPGADesign.(pcsName{1}));
                    blkDP.(pNameInBlk)=csval;
                end
            end

        catch ME
            currBoard=hsb.blkcb2.cbutils('GetHardwareBoard',blkH);
            wrapperCause=MException(message('soc:msgs:CouldNotGetTargetGlobals',currBoard,blkPath));
            ME=ME.addCause(wrapperCause);
            throw(ME);
        end
    else



        pvals=cell([1,length(pNamesInBlk)]);
        blkDP=cell2struct(pvals,pNamesInBlk,2);
        blkDP=hsb.blkcb2.cbutils('CopyDerivedMaskParams',blkP,blkDP);
    end

    blkP=hsb.blkcb2.cbutils('CopyDerivedMaskParams',blkDP,blkP);
end
function currBoard=GetHardwareBoard(blkH)
    sysH=bdroot(blkH);
    cs=getActiveConfigSet(sysH);
    if codertarget.data.isParameterInitialized(cs,'TargetHardware')
        currBoard=codertarget.data.getParameterValue(cs,'TargetHardware');
    else
        currBoard=get_param(cs,'HardwareBoard');
    end
end


function runningState=SimStatusIsRunning(blkH,sysH)

    currStatus=get_param(sysH,'SimulationStatus');
    if(strcmp(currStatus,'running')||...
        strcmp(currStatus,'terminating')||...
        strcmp(get_param(sysH,'ExtModeConnected'),'on')||...
        strcmp(get_param(bdroot(get(blkH,'Parent')),'Lock'),'on'))
        runningState=true;
    else
        runningState=false;
    end
end
function runningState=SimStatusIsStopped(blkH,sysH)
    currStatus=get_param(sysH,'SimulationStatus');
    runningState=strcmp(currStatus,'stopped');
end
function tf=IsLibContext(blkH)
    tf=any(strcmp(get(bdroot(blkH),'Name'),{'socmemlib','soclib','socregisterchanneli2clib','prociolib','proclib_internal'}));
end



...
...
...
...
...
...
...
...
...
...
...
...
...
function[ci,sm,mic]=DeriveMemChParams(p,masterKind,masterID)
    switch masterKind
    case MasterKindEnum.Writer
        citag='WriterChIf';
        smtag='Writer';
        mictag='Writer';
        accessType='WriteAccessBusObj';
        prototag='Writer';
    case MasterKindEnum.Reader
        citag='ReaderChIf';
        smtag='Reader';
        mictag='Reader';
        accessType='ReadAccessBusObj';
        prototag='Reader';
    otherwise
        error(message('soc:msgs:InternalBadMasterKind',char(masterKind)));
    end




    ci.MasterID=masterID;
    ci.MasterKind=masterKind;




    chType=p.(['ChType',citag]);
    ci.ChType=hsb.blkcb2.cbutils('GetRealChType',chType);
    chDimensions=p.(['ChDimensions',citag]);ci.ChDimensions=chDimensions;
    chBitPacked=p.(['ChBitPacked',citag]);

    [ci.ChLength,ci.ChCompLength,ci.ChBitPacked]=hsb.blkcb2.cbutils('GetChLength',chDimensions,chBitPacked);
    [ci.ChWidth,ci.ChTDATAWidth,ci.ChTDATAPadWidth,ci.ChContainerType,chTDATASize]=hsb.blkcb2.cbutils('GetChWidths',chType,ci.ChCompLength);

    ci.ChCompBitRanges=zeros([ci.ChCompLength,2]);
    for cidx=1:ci.ChCompLength
        ci.ChCompBitRanges(cidx,1)=(cidx)*ci.ChWidth;
        ci.ChCompBitRanges(cidx,2)=(cidx-1)*ci.ChWidth+1;
    end


















    switch masterKind
    case MasterKindEnum.Writer,p.(['BufferLength',citag])=0;
    case MasterKindEnum.Reader,p.(['BufferLength',citag])=ceil(p.MRBufferSize/chTDATASize);
    otherwise
        error(message('soc:msgs:InternalBadMasterKind',char(masterKind)));
    end

    ci.ChFrameSampleTime=p.(['ChFrameSampleTime',citag]);
    ci.BufferLength=p.(['BufferLength',citag]);

    validateattributes(ci.ChFrameSampleTime(1),{'numeric'},{'positive'},'',['ChFrameSampleTime',citag]);
    validateattributes(ci.BufferLength,{'numeric'},{'nonnegative','integer','scalar'},'',['BufferLength',citag]);

    if~(isrow(ci.ChFrameSampleTime)&&numel(ci.ChFrameSampleTime)<=2)
        error(message('soc:msgs:ChUnsupportedSampleTime',prototag,mat2str(ci.ChFrameSampleTime)));
    end

    MAX_BURST_BEATS=hsb.blkcb2.cbutils('GetSystemConstant','MAX_BURST_BEATS');
    MAX_BURST_SIZE=hsb.blkcb2.cbutils('GetSystemConstant','MAX_BURST_SIZE');
    MAX_BURST_COUNT=hsb.blkcb2.cbutils('GetSystemConstant','MAX_BURST_COUNT');

    ci.MaximumBurstSize=MAX_BURST_SIZE;

    if strcmp(p.EnableMemSim,'on')
        switch p.(['Protocol',prototag])
        case 'AXI4-Stream Software'









            maxBurstLength=ci.MaximumBurstSize/chTDATASize;
            div=0;
            foundLength=false;
            while~foundLength
                div=div+1;
                tryBurstLength=ci.ChLength/div;
                if hsb.blkcb2.cbutils('IsIntegerValue',tryBurstLength)&&tryBurstLength<=maxBurstLength
                    foundLength=true;
                elseif tryBurstLength<1
                    tryBurstLength=1;
                    foundLength=true;
                end
            end
            ci.BurstLength=tryBurstLength;

        otherwise
            ci.BurstLength=p.(['BurstLength',citag]);
        end

    else
        switch p.(['Protocol',prototag])
        case 'AXI4'
            ci.BurstLength=p.(['BurstLength',citag]);

        otherwise
            ci.BurstLength=p.(['BurstLength',citag]);
            maxBurstLength=ci.MaximumBurstSize/chTDATASize;
            div=0;
            foundLength=false;
            while~foundLength
                div=div+1;
                tryBurstLength=ci.BurstLength/div;
                if hsb.blkcb2.cbutils('IsIntegerValue',tryBurstLength)&&tryBurstLength<=maxBurstLength
                    foundLength=true;
                elseif tryBurstLength<1
                    tryBurstLength=1;
                    foundLength=true;
                end
            end
            ci.BurstLength=tryBurstLength;
        end
    end

    switch p.(['Protocol',prototag])
    case 'AXI4'


        burstMaxLength=min(MAX_BURST_BEATS,ceil(MAX_BURST_SIZE/chTDATASize));
        burstMaxSize=burstMaxLength*chTDATASize;
        ci.MaximumBurstSize=burstMaxSize;





        ci.BurstSize=-1;
        ci.ChGatherCount=-1;
        ci.ChGatherBufferBurstCount=MAX_BURST_COUNT;
        ci.ChFrameGatherBufferSize=ci.ChLength*chTDATASize;





        ci.ChTLASTCount=ceil(ci.ChLength/burstMaxLength);

        if burstMaxLength>=ci.ChLength


            ci.EntityInflowTime=0;
        else


            ci.EntityInflowTime=burstMaxLength*(ci.ChFrameSampleTime(1)/ci.ChLength);
        end






        ci.ChGatherBufferSize=ceil(burstMaxSize/ci.ChFrameGatherBufferSize)*ci.ChFrameGatherBufferSize;

    otherwise
        validateattributes(ci.BurstLength,{'numeric'},{'positive','integer','scalar'},'',['BurstLength',citag]);

        ci.BurstSize=ci.BurstLength*chTDATASize;
        if ci.BurstSize>ci.MaximumBurstSize
            error(message('soc:msgs:BurstSizeTooLarge',ci.BurstLength,ci.ChTDATAWidth,ci.BurstSize,ci.MaximumBurstSize));
        end
        ci.ChGatherCount=ceil(ci.BurstLength/ci.ChLength);
        ci.ChGatherBufferSize=ci.ChGatherCount*ci.ChLength*chTDATASize;
        ci.ChGatherBufferBurstCount=ci.ChGatherBufferSize/ci.BurstSize;

        maxBurstCount=hsb.blkcb2.cbutils('GetSystemConstant','MAX_BURST_COUNT');
        if ci.ChGatherBufferBurstCount>maxBurstCount
            error(message('soc:msgs:BurstCountTooLarge',ci.ChLength,ci.BurstLength,ci.ChGatherBufferBurstCount,maxBurstCount));
        end

        if ci.BurstLength>=ci.ChLength


            ci.EntityInflowTime=0;
        else


            ci.EntityInflowTime=ci.BurstLength*(ci.ChFrameSampleTime(1)/ci.ChLength);
        end

        ci.ChFrameGatherBufferSize=ci.ChLength*chTDATASize;


        ci.ChTLASTCount=round(ci.BufferLength/ci.ChLength);

        if round(ci.ChGatherBufferBurstCount)~=ci.ChGatherBufferBurstCount
            error(message('soc:msgs:ChAndBurstLength',ci.BurstLength,ci.ChLength));
        end
    end


    [ci.InsertInactivePixelClocks,ci.ActivePixelsPerLine,ci.ActiveVideoLines,ci.PorchCount,ci.BlankingCount]=...
    hsb.blkcb2.cbutils('DeriveVideoFrameParams',p,masterKind,masterID);


    ci.InterruptHandlingTime=p.(['InterruptHandlingTime',citag]);
    ci.BufferEventID=p.(['BufferEventID',citag]);
    ci.NumberOfBuffers=p.MRNumBuffers;




    sm.MasterID=masterID;
    sm.MasterKind=masterKind;
    sm.MaxSize=ci.BurstSize;
    switch p.(['Protocol',prototag])
    case 'AXI4'
        sm.ICDataWidth=ci.ChTDATAWidth;
    otherwise
        sm.ICDataWidth=p.(['ICDataWidth',smtag]);
    end
    sm.BufferLengthInBursts=p.MRBufferSize/ci.BurstSize;
    sm.MRMaximumAccessSize=ci.MaximumBurstSize;
    sm.AlignedBufBoundary=p.MRRegionSize/p.MRNumBuffers;




    mic.MasterID=masterID;
    mic.MasterKind=masterKind;
    mic.MasterSim=p.EnableMemSim;
    mic.EntityInflowQueueCapacity=ci.ChGatherBufferBurstCount*2;
    mic.EntityInflowTime=ci.EntityInflowTime;
    mic.AccessTransactionType=accessType;
    mic.BufferLengthInBursts=sm.BufferLengthInBursts;
    switch p.(['Protocol',prototag])
    case 'AXI4-Stream Software'
        mic.FIFODepth=sm.BufferLengthInBursts*ci.NumberOfBuffers;
        mic.FIFOAFullDepth=sm.BufferLengthInBursts*ci.NumberOfBuffers;
        mic.ICDataWidth=p.(['ICDataWidth',mictag]);
    case 'AXI4'
        mic.FIFODepth=max(2,ceil(ci.ChLength/burstMaxLength));
        mic.FIFOAFullDepth=max(2,ceil(ci.ChLength/burstMaxLength));
        mic.ICDataWidth=ci.ChTDATAWidth;
    otherwise
        mic.FIFODepth=p.(['FIFODepth',mictag]);
        mic.FIFOAFullDepth=p.(['FIFOAFullDepth',mictag]);
        mic.ICDataWidth=p.(['ICDataWidth',mictag]);
    end
    ci.FIFODepth=max(mic.FIFODepth,ci.ChGatherBufferBurstCount);
    ci.FIFOAFullDepth=max(mic.FIFOAFullDepth,ci.ChGatherBufferBurstCount);

    mic.ICClockFrequency=p.(['ICClockFrequency',mictag]);

end
function realChType=GetRealChType(chType)
    if isa(chType,'Simulink.AliasType')
        if strncmp(chType.BaseType,'fixdt',5)
            realChType=eval(chType.BaseType);
        else
            realChType=chType.BaseType;
        end
    else
        realChType=chType;
    end
end
function[pcc,fname]=GetPixelClockCount(videoFrameSize)
    switch videoFrameSize
    case 1,pcc=1;fname='test';
    case 16*12,pcc=18*14;fname='16x12p (test mode)';
    case 160*120,pcc=180*140;fname='160x120p';
    case 720*480,pcc=858*525;fname='480p SDTV (720x480p)';
    case 720*576,pcc=864*625;fname='576p SDTV (720x576p)';
    case 1280*720,pcc=1650*750;fname='720p HDTV (1280x720p)';
    case 1920*1080,pcc=2200*1125;fname='1080p HDTV (1920x1080p)';
    case 320*240,pcc=402*324;fname='320x240p';
    case 640*480,pcc=800*525;fname='640x480p';
    case 800*600,pcc=1056*628;fname='800x600p';
    case 1024*768,pcc=1344*806;fname='1024x768p';
    case 1280*768,pcc=1664*798;fname='1280x768p';
    case 1280*1024,pcc=1688*1066;fname='1280x1024p';
    case 1360*768,pcc=1792*795;fname='1360x768p';
    case 1366*768,pcc=1792*798;fname='1366x768p';
    case 1400*1050,pcc=1864*1089;fname='1400x1050p';
    case 1600*1200,pcc=2160*1250;fname='1600x1200p';
    case 1680*1050,pcc=2240*1089;fname='1680x1050p';
    case 1920*1200,pcc=2080*1235;fname='1920x1200p';
    otherwise
        pcc=0;
        fname='';
    end
end
function dp=DeriveVideoFrameParamsTb(videoFrameSize)



    switch videoFrameSize
    case '16x12p (test mode)',apl=16;avl=12;tpl=18;tvl=14;
    case '160x120p',apl=160;avl=120;tpl=180;tvl=140;
    case '480p SDTV (720x480p)',apl=720;avl=480;tpl=858;tvl=525;
    case '576p SDTV (720x576p)',apl=720;avl=576;tpl=864;tvl=625;
    case '720p HDTV (1280x720p)',apl=1280;avl=720;tpl=1650;tvl=750;
    case '1080p HDTV (1920x1080p)',apl=1920;avl=1080;tpl=2200;tvl=1125;
    case '320x240p',apl=320;avl=240;tpl=402;tvl=324;
    case '640x480p',apl=640;avl=480;tpl=800;tvl=525;
    case '800x600p',apl=800;avl=600;tpl=1056;tvl=628;
    case '1024x768p',apl=1024;avl=768;tpl=1344;tvl=806;
    case '1280x768p',apl=1280;avl=768;tpl=1664;tvl=798;
    case '1280x1024p',apl=1280;avl=1024;tpl=1688;tvl=1066;
    case '1360x768p',apl=1360;avl=768;tpl=1792;tvl=795;
    case '1366x768p',apl=1366;avl=768;tpl=1792;tvl=798;
    case '1400x1050p',apl=1400;avl=1050;tpl=1864;tvl=1089;
    case '1600x1200p',apl=1600;avl=1200;tpl=2160;tvl=1250;
    case '1680x1050p',apl=1680;avl=1050;tpl=2240;tvl=1089;
    case '1920x1200p',apl=1920;avl=1200;tpl=2080;tvl=1235;
    otherwise
        error(message('soc:msgs:UnsupportedVideoFrameSize',videoFrameSize));
    end
    dp=struct('ActivePixelsPerLine',apl,'ActiveVideoLines',avl,...
    'PorchCount',tpl-apl,'BlankingCount',tvl-avl);

end
function[insInactive,actPixPerLine,actVidLines,porch,blanking]=DeriveVideoFrameParams(p,masterKind,masterID)%#ok<INUSD>


    isVidReader=(masterKind==MasterKindEnum.Reader)&&...
    (any(strcmp(p.ProtocolReader,{'AXI4-Stream Video','AXI4-Stream Video with Frame Sync'})));

    if isVidReader
        switch p.InsertInactivePixelClocksReaderChIf
        case 'on',insInactive=true;
        case 'off',insInactive=false;
        end
        switch p.FrameSizeReaderChIf
        case '16x12p (test mode)',apl=16;avl=12;tpl=18;tvl=14;
        case '160x120p',apl=160;avl=120;tpl=180;tvl=140;
        case '480p SDTV (720x480p)',apl=720;avl=480;tpl=858;tvl=525;
        case '576p SDTV (720x576p)',apl=720;avl=576;tpl=864;tvl=625;
        case '720p HDTV (1280x720p)',apl=1280;avl=720;tpl=1650;tvl=750;
        case '1080p HDTV (1920x1080p)',apl=1920;avl=1080;tpl=2200;tvl=1125;
        case '320x240p',apl=320;avl=240;tpl=402;tvl=324;
        case '640x480p',apl=640;avl=480;tpl=800;tvl=525;
        case '800x600p',apl=800;avl=600;tpl=1056;tvl=628;
        case '1024x768p',apl=1024;avl=768;tpl=1344;tvl=806;
        case '1280x768p',apl=1280;avl=768;tpl=1664;tvl=798;
        case '1280x1024p',apl=1280;avl=1024;tpl=1688;tvl=1066;
        case '1360x768p',apl=1360;avl=768;tpl=1792;tvl=795;
        case '1366x768p',apl=1366;avl=768;tpl=1792;tvl=798;
        case '1400x1050p',apl=1400;avl=1050;tpl=1864;tvl=1089;
        case '1600x1200p',apl=1600;avl=1200;tpl=2160;tvl=1250;
        case '1680x1050p',apl=1680;avl=1050;tpl=2240;tvl=1089;
        case '1920x1200p',apl=1920;avl=1200;tpl=2080;tvl=1235;
        otherwise
            error(message('soc:msgs:UnsupportedVideoFrameSize',videoFrameSize));
        end
        actPixPerLine=apl;
        actVidLines=avl;
        porch=tpl-apl;
        blanking=tvl-avl;
    else
        insInactive=false;
        actPixPerLine=0;
        actVidLines=0;
        porch=0;
        blanking=0;
    end

end

function[chOrder,chOrderR,chDimensions]=GetChOrder(chDimensions,chBitPacked)



    numDim=numel(chDimensions);
    if strcmp(chBitPacked,'on')&&(chDimensions(end)>1)
        if numDim>1
            chOrder=[numDim,1:numDim-1];
            chOrderR=[2:numDim,1];
            chDimensions=[chDimensions(end),chDimensions(1:end-1)];
        else
            chOrder=1:numDim+1;
            chOrderR=1:numDim;
            chDimensions=chDimensions;
        end
    else
        chOrder=1:numDim+1;
        chOrderR=1:numDim;
        chDimensions=chDimensions;
    end
end
function[chLength,chCompLength,chBitPacked]=GetChLength(chDimensions,chBitPacked)




    if strcmp(chBitPacked,'on')&&(chDimensions(end)>1)
        if numel(chDimensions)>1
            chLength=prod(chDimensions(1:end-1));
        else
            chLength=1;
        end
        chCompLength=chDimensions(end);
        chBitPacked=true;
    else
        chLength=prod(chDimensions(1:end));
        chCompLength=1;
        chBitPacked=false;
    end
end
function[chWidth,chTDATAWidth,chTDATAPadWidth,chContainerType,chTDATASize]=GetChWidths(chType,chCompLength,varargin)
    chType=hsb.blkcb2.cbutils('GetRealChType',chType);
    switch class(chType)
    case 'char'
        switch chType
        case{'uint8','uint16','uint32','uint64'}
            chWidth=eval(chType(5:end));
            chSign='u';
        case{'int8','int16','int32','int64'}
            chWidth=eval(chType(4:end));
            chSign='';
        case 'single'
            chWidth=32;
            chSign='';
        case 'double'
            chWidth=64;
            chSign='';
        otherwise
            error(message('soc:msgs:ChUnsupportedType',chType));
        end
    case 'Simulink.NumericType'
        chWidth=chType.WordLength;
        if strcmp(chType.Signedness,'Signed')
            chSign='';
        else
            chSign='u';
        end
    otherwise
        error(message('soc:msgs:ChUnsupportedType',class(chType)));
    end

    if chWidth>128
        error(message('soc:msgs:DWGreaterThan128',chWidth));
    end

    chActiveDataWidth=chWidth*chCompLength;

    if any(strcmp(chType,{'single','double'}))

        assert(chCompLength==1,'Component length must be 1 for single or double ch types');
        chTDATAWidth=chWidth;
        chContainerType=sprintf('%s',chType);
    else
        switch(chActiveDataWidth)
        case num2cell(1:8),chContainerWidth=8;chTDATAWidth=8;
        case num2cell(9:16),chContainerWidth=16;chTDATAWidth=16;
        case num2cell(17:32),chContainerWidth=32;chTDATAWidth=32;
        case num2cell(33:64),chContainerWidth=64;chTDATAWidth=64;
        case num2cell(65:128),chContainerWidth=64;chTDATAWidth=128;
        case num2cell(129:512),chContainerWidth=64;chTDATAWidth=double(idivide(uint32(chActiveDataWidth),uint32(chContainerWidth),'ceil')*64);
        otherwise
            error(message('soc:msgs:ChBitPackedWidth',chWidth,chCompLength,chActiveDataWidth));
        end

        if chTDATAWidth>64
            chContainerType=sprintf('uint64');
        else
            chContainerType=sprintf('%sint%d',chSign,chContainerWidth);
        end
    end
    chTDATAPadWidth=chTDATAWidth-chActiveDataWidth;
    chTDATASize=chTDATAWidth/8;
end


function[sysConst,ImageName,PortName,Value,IOType]=GetSystemConstant(what,currBoard,NoOfOpts)
    switch what
    case 'MAX_BURST_SIZE',sysConst=4096;
    case 'MAX_BURST_BEATS',sysConst=256;



    case 'MAX_BURST_COUNT',sysConst=1e6/2;
    case 'MAX_BLK_HMI_INPUTS',sysConst=8;
    case 'MAX_BLK_HMI_OUTPUTS',sysConst=16;
    case 'MAX_LEDS'
        switch currBoard
        case 'ZedBoard',sysConst=8;
            NoOfOpts.TypeOptions={'1','2','3','4','5','6','7','8'};
            ImageName='ZedBoard_LED.png';
            PortName='LED';
        case 'Xilinx Zynq ZC706 evaluation kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='ZC706_LEDs.png';
            PortName='LED';
        case 'Xilinx Kintex-7 KC705 development board',sysConst=8;
            NoOfOpts.TypeOptions={'1','2','3','4','5','6','7','8'};
            ImageName='KC705_LEDs.png';
            PortName='LED';
        case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit',sysConst=8;
            NoOfOpts.TypeOptions={'1','2','3','4','5','6','7','8'};
            ImageName='MPSoC_ZCU102_LEDs.png';
            PortName='LED';
        case 'Artix-7 35T Arty FPGA evaluation kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='ArtyBoard_LEDs.png';
            PortName='LED';
        case 'Altera Arria 10 SoC development kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='Arria10SoC_LEDs.png';
            PortName='nLED';
        case 'Altera Cyclone V SoC development kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='CycloneV_LEDs.png';
            PortName='nLED';
        case codertarget.internal.getCustomHardwareBoardNamesForSoC
            IOInfo=soc.internal.getIOInfo(currBoard);
            sysConst=IOInfo.LED.Value;
            NoOfOpts.TypeOptions=split(num2str(1:sysConst));
            IOType=IOInfo.LED.Logic;
            if strcmp(currBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU111 Evaluation Kit')
                ImageName='ZCU111_LEDs.png';
            elseif strcmp(currBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU216 Evaluation Kit')
                ImageName='ZCU216_LEDs.png';
            elseif strcmp(currBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU208 Evaluation Kit')
                ImageName='ZCU208_LEDs.png';

            else
                ImageName='';
            end
            if strcmp(IOType,'Active High')
                PortName='LED';
            else
                PortName='nLED';
            end
            if sysConst==0
                error(message('soc:msgs:NotSupportedZeroLEDsDIPSPBs','LEDs'));
            elseif sysConst>24
                error(message('soc:msgs:NumberOfLEDsDIPsPBsGreaterthan16or8NotSupported','LEDs','24'));
            end
        otherwise
            sysConst=24;
            NoOfOpts.TypeOptions=split(num2str(1:sysConst));
            ImageName='None_LEDs.png';
            PortName='LED';
        end

    case 'pushbuttons'
        switch currBoard
        case 'ZedBoard',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='ZedBoard_PBs.png';
            PortName='PB';
            Value=true;
        case 'Xilinx Zynq ZC706 evaluation kit',sysConst=3;
            NoOfOpts.TypeOptions={'1','2','3'};
            ImageName='ZC706_PBs.png';
            PortName='PB';
            Value=true;
        case 'Xilinx Kintex-7 KC705 development board',sysConst=5;
            NoOfOpts.TypeOptions={'1','2','3','4','5'};
            ImageName='KC705_PBs.png';
            PortName='PB';
            Value=true;
        case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit',sysConst=5;
            NoOfOpts.TypeOptions={'1','2','3','4','5'};
            ImageName='MPSoC_ZCU102_PBs.png';
            PortName='PB';
            Value=true;
        case 'Artix-7 35T Arty FPGA evaluation kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='ArtyBoard_PBs.png';
            PortName='PB';
            Value=true;
        case 'Altera Arria 10 SoC development kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='Arria10SoC_PBs.png';
            PortName='nPB';
            Value=false;
        case 'Altera Cyclone V SoC development kit',sysConst=2;
            NoOfOpts.TypeOptions={'1','2'};
            ImageName='CycloneV_PBs.png';
            PortName='nPB';
            Value=false;
        case codertarget.internal.getCustomHardwareBoardNamesForSoC
            IOInfo=soc.internal.getIOInfo(currBoard);
            sysConst=IOInfo.PB.Value;
            NoOfOpts.TypeOptions=split(num2str(1:sysConst));
            IOType=IOInfo.PB.Logic;
            if strcmp(currBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU111 Evaluation Kit')
                ImageName='ZCU111_PBs.png';
            elseif strcmp(currBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU216 Evaluation Kit')
                ImageName='ZCU216_PBs.png';

            elseif strcmp(currBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU208 Evaluation Kit')
                ImageName='ZCU208_PBs.png';
            else
                ImageName='';
            end
            if strcmp(IOType,'Active High')
                PortName='PB';
                Value=true;
            else
                PortName='nPB';
                Value=false;
            end
            if sysConst==0
                error(message('soc:msgs:NotSupportedZeroLEDsDIPSPBs','Push Buttons'));
            elseif sysConst>8
                error(message('soc:msgs:NumberOfLEDsDIPsPBsGreaterthan16or8NotSupported','Push Buttons','8'));
            end
        otherwise
            sysConst=8;
            NoOfOpts.TypeOptions={'1','2','3','4','5','6','7','8'};
            ImageName='None_PBs.png';
            PortName='PB';
            Value=true;
        end
    case 'dipswitches'
        switch currBoard
        case 'ZedBoard',sysConst=8;
            NoOfOpts.TypeOptions={'1','2','3','4','5','6','7','8'};
            ImageName='ZedBoard_DIPSW.png';
            PortName='DS';
            Value=true;
        case 'Xilinx Zynq ZC706 evaluation kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='ZC706_DPSWs.png';
            PortName='DS';
            Value=true;
        case 'Xilinx Kintex-7 KC705 development board',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='KC705_DPSWs.png';
            PortName='DS';
            Value=true;
        case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit',sysConst=8;
            NoOfOpts.TypeOptions={'1','2','3','4','5','6','7','8'};
            ImageName='MPSoC_ZCU102_DPSWs.png';
            PortName='DS';
            Value=true;
        case 'Artix-7 35T Arty FPGA evaluation kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='ArtyBoard_DPSW.png';
            PortName='DS';
            Value=true;
        case 'Altera Arria 10 SoC development kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='Arria10SoC_DPSWs.png';
            PortName='nDS';
            Value=false;
        case 'Altera Cyclone V SoC development kit',sysConst=4;
            NoOfOpts.TypeOptions={'1','2','3','4'};
            ImageName='CycloneV_DPSws.png';
            PortName='nDS';
            Value=false;
        case codertarget.internal.getCustomHardwareBoardNamesForSoC
            IOInfo=soc.internal.getIOInfo(currBoard);
            sysConst=IOInfo.DIP.Value;
            NoOfOpts.TypeOptions=split(num2str(1:sysConst));
            IOType=IOInfo.DIP.Logic;
            if strcmp(currBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU111 Evaluation Kit')
                ImageName='ZCU111_DPSWs.png';
            elseif strcmp(currBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU216 Evaluation Kit')
                ImageName='ZCU216_DPSWs.png';

            elseif strcmp(currBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU208 Evaluation Kit')
                ImageName='ZCU208_DPSWs.png';
            else
                ImageName='';
            end
            if strcmp(IOType,'Active High')
                PortName='DS';
                Value=true;
            else
                PortName='nDS';
                Value=false;
            end
            if sysConst==0
                error(message('soc:msgs:NotSupportedZeroLEDsDIPSPBs','DIP Switches'));
            elseif sysConst>8
                error(message('soc:msgs:NumberOfLEDsDIPsPBsGreaterthan16or8NotSupported','DIP Switches','8'));
            end
        otherwise
            sysConst=8;
            NoOfOpts.TypeOptions={'1','2','3','4','5','6','7','8'};
            ImageName='None_DIPSW.png';
            PortName='DS';
            Value=true;
        end
    otherwise
        error('bad system constant ''%s''',what,currBoard);
    end

end

function pblkNames=MemChBlockParamNames()
    pblkNames={'ICClockFrequencyWriter','ICClockFrequencyReader',...
    'ICDataWidthWriter','ICDataWidthReader',...
    'FIFODepthWriter','FIFODepthReader',...
    'FIFOAFullDepthWriter','FIFOAFullDepthReader'};
end
function pcsNames=MemChConfigSetParamNames()
    pcsNames={'AXIMemoryInterconnectInputClock','AXIMemoryInterconnectInputClock',...
    'AXIMemoryInterconnectInputDataWidth','AXIMemoryInterconnectInputDataWidth',...
    'AXIMemoryInterconnectFIFODepth','AXIMemoryInterconnectFIFODepth',...
    'AXIMemoryInterconnectFIFOAFullDepth','AXIMemoryInterconnectFIFOAFullDepth'};
end
function pblkNames=MemCtrlrBlockParamNames()
    pblkNames={'ControllerFrequency',...
    'ControllerDataWidth',...
    'BandwidthDerating',...
    'WriteFirstTransferLatency',...
    'ReadFirstTransferLatency',...
    'WriteLastTransferLatency',...
    'ReadLastTransferLatency'};
end
function pcsNames=MemCtrlrConfigSetParamNames()
    pcsNames={'AXIMemorySubsystemClock',...
    'AXIMemorySubsystemDataWidth',...
    'RefreshOverhead',...
    'WriteFirstTransferLatency',...
    'ReadFirstTransferLatency',...
    'WriteLastTransferLatency',...
    'ReadLastTransferLatency'};
end
function pblkNames=DummyMasterBlockParamNames()
    pblkNames={'ControllerDataWidth'};
end
function pcsNames=DummyMasterConfigSetParamNames()
    pcsNames={'AXIMemorySubsystemDataWidth'};
end

function checkSoCBlocksetLicense()

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end
end
