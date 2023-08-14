function modelResavePresaveCallback(caller,mdlName)%#ok<INUSL>



















    mdlInfo=l_getModelInfo(mdlName);
    disp('## model info on entry:');
    disp(mdlInfo);


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
...

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



    commonArgs={'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FirstResultOnly','on'};

    info.hasMemChannel=~isempty(find_system(mdlName,commonArgs{:},'ReferenceBlock','socmemlib/Memory Channel'));
    info.hasMemController=~isempty(find_system(mdlName,commonArgs{:},'ReferenceBlock','socmemlib/Memory Controller'));
    info.hasObsoleteRegCh=~isempty(find_system(mdlName,commonArgs{:},'ReferenceBlock','hsblib_beta2/Register Channel'));
    info.hasRegChannel=~isempty(find_system(mdlName,commonArgs{:},'ReferenceBlock','socmemlib/Register Channel'));

    if info.hasMemChannel||info.hasMemController
        warn=codertarget.fpgadesign.internal.fpgaDesignCallback(get_param(mdlName,'Handle'),'checkFPGACompatibility','blockInstantiation',mdlName);
        info.fpgaSupportedBoard=~warn;
    else


        info.fpgaSupportedBoard=false;
    end
end
function tf=l_isCtrlDException(mdlName)
    tf=any(strcmp(mdlName,{...
    '',...
    }));
end


function l_ensureSupportedBoard(mdlName,mdlInfo)
    if mdlInfo.hasMemChannel||mdlInfo.hasMemController
        if~mdlInfo.fpgaSupportedBoard
            warning('Updating model from unsupported FPGA board to Custom Hardware Board');
            soc.internal.build.setTargetHardware(mdlName,'Custom Hardware Board');
        end
    end
end
function l_clearHSBMPM(mdlName,mdlInfo)
    if mdlInfo.hasHSBMPM
        mws=get_param(mdlName,'ModelWorkspace');
        hsbmpm=mws.getVariable('hsbmpm');
        memChBlks=keys(hsbmpm.wtop);
        for mcb=memChBlks
            blkPath=split(mcb{1},'/');


            foundBlk=find_system(mdlName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name',blkPath{end});
            if~isempty(foundBlk)&&strcmp(get_param(mcb{1},'ReferenceBlock'),'socmemlib/Memory Channel')
                disp(['## transferring wtop values to block mask for ',mcb{1}]);
                wtop=hsbmpm.wtop(mcb{1});
                params=fieldnames(wtop);
                for p=params'
                    issP.([p{1},'WriterChIf'])=wtop.(p{1});
                end
                issP=l_getInpSigSpecOverrides(mcb{1},issP);
                hsb.blkcb2.cbutils('SetDerivedMaskParams',mcb{1},issP);
            end
        end
        disp('## clearing hsbmpm from model workspace');
        mws.clear('hsbmpm');
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
    otherwise

    end
end
