function fixupSoCBModel(mdlName,action)





    supportedActions={...
    'showModelInfo',...
    'ensureSupportedBoard',...
    'transferWTOPToBlockMask',...
    'deleteHSBMPM',...
    'tryCtrlD',...
    'displayModelAnnotations',...
    'placeWindowAndSize',...
    'ensureCleanDiagLevel',...
    'dummyInteraccessTimes',...
'ICFIFOdepthUpdate'...
    };
    if~any(strcmp(action,supportedActions))
        error('Supported actions are: %s',sprintf('%s ',supportedActions{:}));
    end

    try
        disp(['## ----------- attempting action: ',action,' --------------------']);
        info=l_getModelInfo(mdlName);
        disp('## model info on entry:');
        disp(info);
        feval(action,mdlName,info);
        disp(['## completed action: ',action]);
    catch ME
        error('Could not execute action %s.  Saw error:\n %s',...
        action,...
        ME.getReport());
    end

    info=l_getModelInfo(mdlName);
    disp('## model info on exit:');
    disp(info);

end

function showModelInfo(mdlName,mdlInfo)
    disp('## no action taken.  just showing model info.');
end

function ensureSupportedBoard(mdlName,mdlInfo)%#ok<*DEFNU>
    if mdlInfo.hasMemChannel||mdlInfo.hasMemController
        if~mdlInfo.fpgaSupportedBoard
            warning('## Updating model from unsupported FPGA board to Custom Hardware Board');
            soc.internal.build.setTargetHardware(mdlName,'Custom Hardware Board');
        else
            disp('## board already supported.  no action taken.');
        end
    end
end

function transferWTOPToBlockMask(mdlName,mdlInfo)
    if mdlInfo.hasHSBMPM
        mws=get_param(mdlName,'ModelWorkspace');
        hsbmpm=mws.getVariable('hsbmpm');
        memChBlks=keys(hsbmpm.wtop);
        for mcb=memChBlks
            blkPath=split(mcb{1},'/');
            assert(length(blkPath)==2,'could not parse block path ''%s'': we assume mem ch in top model',mcb{1});


            foundBlock=strcmp(blkPath{1},mdlName)&&...
            ~isempty(find_system(blkPath{1},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name',blkPath{2}));
            if foundBlock&&strcmp(get_param(mcb{1},'ReferenceBlock'),'socmemlib/Memory Channel')
                disp(['## transferring wtop values to block mask for ',mcb{1}]);
                wtop=hsbmpm.wtop(mcb{1});
                params=fieldnames(wtop);
                for p=params'
                    issP.([p{1},'WriterChIf'])=wtop.(p{1});
                end
                issP=l_getInpSigSpecOverrides(mcb{1},issP);
                hsb.blkcb2.cbutils('SetDerivedMaskParams',mcb{1},issP);
            else
                disp('## no wtop usage found. no action taken.');
            end
        end
    else
        disp('## no hsbmpm found.  no action taken.');
    end
end

function deleteHSBMPM(mdlName,mdlInfo)
    if mdlInfo.hasHSBMPM
        mws=get_param(mdlName,'ModelWorkspace');
        hsbmpm=mws.getVariable('hsbmpm');%#ok<NASGU>
        disp('## clearing hsbmpm from model workspace');
        mws.clear('hsbmpm');
    else
        disp('## no hsbmpm found.  no changes required.');
    end
end

function tryCtrlD(mdlName,mdlInfo)%#ok<*INUSD>
    try
        disp('## attempting to ctrl-d model');
        set_param(mdlName,'SimulationCommand','update');
        disp('## ... PASSED');
    catch ME
        warning('## ... FAILED: %s',ME.getReport);
    end
end

function placeWindowAndSize(mdlName,mdlInfo)
    set_param(mdlName,'Location',[20,20,1280,720]);pause(0.5);
    set_param(mdlName,'ZoomFactor','FitSystem');pause(0.5);
end

function displayModelAnnotations(mdlName,mdlInfo)
    set_param(mdlName,'ShowLineDimensions','on');pause(0.5);
    set_param(mdlName,'ShowPortDataTypes','on');pause(0.5);
    set_param(mdlName,'SampleTimeAnnotations','on');pause(0.5);
    set_param(mdlName,'SampleTimeColors','on');pause(0.5);
end

function ensureCleanDiagLevel(mdlName,mdlInfo)
    if mdlInfo.hasMemChannel||mdlInfo.hasMemController
        sysH=bdroot(mdlName);
        hsb.blkcb2.cbutils('SetCSParam',sysH,{'MemChDiagLevel','No debug'});
        pause(10);
        hsb.blkcb2.cbutils('SetCSParam',sysH,{'MemChDiagLevel','Basic diagnostic signals'});
        pause(10);
    else
        disp('## no mem channel or mem controller. no action taken.');
    end
end

function dummyInteraccessTimes(mdlName,mdlInfo)
    if mdlInfo.hasDummyMaster


        foundBlocks=find_system(mdlName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Traffic Generator');
        for b=foundBlocks


            fullIAC=get_param(b{1},'BurstInterAccessTimes');
            parsedIAC=split(strtrim(regexprep(fullIAC,'[\[\],]',' ')));
            [startT,minT,maxT]=parsedIAC{:};
            disp(['## porting parameters for dummy master ',b{1}]);
            set_param(b{1},'FirstBurstTime',startT,...
            'TimeBetweenBursts',minT,...
            'MinMaxBetweenBursts',['[',minT,',',maxT,']']);
        end
    else
        disp('## no dummy master. no action taken.');
    end
end



function info=l_getModelInfo(mdlName)
    info.name=mdlName;
    info.board=get_param(mdlName,'HardwareBoard');
    info.device=get_param(mdlName,'ProdHWDeviceType');
    info.solverType=get_param(mdlName,'SolverType');

    info.hasHSBMPM=false;
    mws=get_param(mdlName,'ModelWorkspace');
    if~isempty(mws)
        if mws.hasVariable('hsbmpm')
            info.hasHSBMPM=true;
        end
    end

    info.hasMemChannel=~isempty(find_system(mdlName,'FirstResultOnly','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Channel'));
    info.hasMemController=~isempty(find_system(mdlName,'FirstResultOnly','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Controller'));
    info.hasObsoleteRegCh=~isempty(find_system(mdlName,'FirstResultOnly','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','hsblib_beta2/Register Channel'));
    info.hasRegChannel=~isempty(find_system(mdlName,'FirstResultOnly','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Register Channel'));
    info.hasDummyMaster=~isempty(find_system(mdlName,'FirstResultOnly','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Traffic Generator'));

    if info.hasMemChannel||info.hasMemController
        warn=codertarget.fpgadesign.internal.fpgaDesignCallback(get_param(mdlName,'Handle'),'checkFPGACompatibility','blockInstantiation',mdlName);
        info.fpgaSupportedBoard=~warn;
    else


        info.fpgaSupportedBoard=false;
    end
end

function issP=l_getInpSigSpecOverrides(memchPath,issP)
    switch memchPath

    case{'hsb_esb_catchup_ramp/Mem Channel',...
        'hsb_esb_getting_started_ramp_top/Mem Channel'}
        issP.ChFrameSampleTimeWriterChIf='1/(hsbesbrampparams.FPGA_fs*1e6)';
    case 'hsb_esb_histogram_equalization/Frame Buffer'
        issP.ChDimensionsWriterChIf='histeqp.DUTChDims';
        issP.ChTypeWriterChIf='histeqp.DUTChType';
        issP.ChFrameSampleTimeWriterChIf='histeqp.DUTChSTime';
    case 'hsb_FFT_2D/Input Read Memory Channel'
        issP.ChDimensionsWriterChIf='fftLength';
    case 'hsb_histogram_equalization/Frame Buffer'
        issP.ChDimensionsWriterChIf='histeqp.DUTChDims';
        issP.ChTypeWriterChIf='histeqp.DUTChType';
        issP.ChFrameSampleTimeWriterChIf='histeqp.DUTChSTime';
    case 'hsb_histogram_equalization/Mem Channel (read)'
        issP.ChDimensionsWriterChIf='histeqp.FrameChDims';
        issP.ChTypeWriterChIf='histeqp.FrameChType';
        issP.ChFrameSampleTimeWriterChIf='histeqp.FrameChSampTime';
    case 'hsb_histogram_equalization/Mem Channel (write)'
        issP.ChDimensionsWriterChIf='histeqp.DUTChDims';
        issP.ChTypeWriterChIf='histeqp.DUTChType';
        issP.ChFrameSampleTimeWriterChIf='histeqp.DUTChSTime';
    case 'hsb_programmable_filter/Mem Channel Input'
        issP.ChDimensionsWriterChIf='[progfilt.chirpSize 1]';
        issP.ChFrameSampleTimeWriterChIf='progfilt.tbSTime';
    case 'hsb_programmable_filter/Mem Channel Output'
        issP.ChDimensionsWriterChIf='progfilt.dutChDims';
        issP.ChFrameSampleTimeWriterChIf='progfilt.DUTSTime';
    case 'soc_image_rotation/Input Read Memory Channel'
        issP.ChDimensionsWriterChIf='matricRows*matricColumns';

        issP.ChTypeWriterChIf='dt';
    case 'soc_image_rotation/Output Write Memory Channel'


        issP.ChTypeWriterChIf='dt';
    case 'hsb_vision_reference/Mem Channel (read)'
        issP.ChDimensionsWriterChIf='vrefp.FrameChDims';
        issP.ChTypeWriterChIf='vrefp.FrameChType';
        issP.ChFrameSampleTimeWriterChIf='vrefp.FrameChSampTime';
    case 'hsb_vision_reference/Mem Channel (write)'
        issP.ChDimensionsWriterChIf='vrefp.DUTChDims';
        issP.ChTypeWriterChIf='vrefp.DUTChType';
        issP.ChFrameSampleTimeWriterChIf='vrefp.DUTChSTime';
    otherwise

    end
end

function ICFIFOdepthUpdate(mdlName,info)
    if info.hasMemChannel


        blkName=find_system(mdlName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Channel');
        for i=1:numel(blkName)
            if any(strcmp(get_param(blkName{i},'ChannelType'),{'AXI4-Stream to Software via DMA','AXI4-Stream FIFO','Software to AXI4-Stream via DMA'}))
                pNewVal=str2double(get_param(blkName{i},'FIFODepthWriter'));
                if pNewVal<2
                    value='2';
                elseif pNewVal>32
                    value='32';
                else
                    value=num2str(2^nextpow2(pNewVal));
                end
                if strcmp(get_param(blkName{i},'UseValuesFromTargetHardwareResources'),'off')
                    set_param(blkName{i},'FIFODepthWriter',value);
                    if strcmp(get_param(blkName{i},'ReaderWriterUseSameValues'),'off')
                        set_param(blkName{i},'FIFODepthReader',value);
                    end
                else
                    cs=getActiveConfigSet(mdlName);
                    codertarget.data.setParameterValue(cs,'FPGADesign.AXIMemoryInterconnectFIFODepth',value);
                end
            end
        end
    end
end
