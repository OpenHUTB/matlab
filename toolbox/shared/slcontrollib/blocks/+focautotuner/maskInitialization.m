function[numLoops,sigIndexes,DataType,focBlock]=maskInitialization(blkh)









    numLoops=1;
    sigIndexes=[1,1,1,1];

    blkObj=get_param(blkh,'Object');
    blkPath=getfullname(blkh);
    DataType=lower(blkObj.BlockDataType);
    focBlock=blkh;
    pidBlock=horzcat(blkPath,'/PID Autotuner/Closed-Loop PID Autotuner');

    focshared(focBlock);


    invalidStatus={'external','running','compiled','restarting','paused','terminating'};
    if any(strcmpi(get_param(bdroot(blkh),'SimulationStatus'),invalidStatus))
        return
    end


    isTuneSpeed=strcmp(blkObj.TuneSpeedLoop,'on');
    isTuneFlux=strcmp(blkObj.TuneFluxLoop,'on');
    isTuneQaxis=strcmp(blkObj.TuneQaxisLoop,'on');
    isTuneDaxis=strcmp(blkObj.TuneDaxisLoop,'on');
    isStartStopExt=strcmp(blkObj.UseExternalSourceStartStop,'on');
    isBandwidthExt=strcmp(blkObj.UseExternalWc,'on');
    isPhaseMarginExt=strcmp(blkObj.UseExternalPM,'on');
    isSineAmpExt=strcmp(blkObj.UseExternalAmpSine,'on');
    isAchievedPMOut=strcmp(blkObj.UseExternalAchievedPM,'on');
    isFRDOut=strcmp(blkObj.UseExternalFRD,'on');
    isU0Out=strcmp(blkObj.UseExternalU0,'on');
    isActiveLoopOut=strcmp(blkObj.UseExternalActiveLoop,'on')&&~isStartStopExt;


    if~(isTuneSpeed||isTuneFlux||isTuneDaxis||isTuneQaxis)
        error(message('SLControllib:focautotuner:errNoLoopsSelected'));
    end


    focautotuner.utilBlockDialogParameterCheck(blkh);




    localEnableTuningLoop(blkPath,'speed tuning enabled',isTuneSpeed)


    localEnableTuningLoop(blkPath,'flux tuning enabled',isTuneFlux)


    localEnableTuningLoop(blkPath,'qaxis tuning enabled',isTuneQaxis)


    localEnableTuningLoop(blkPath,'daxis tuning enabled',isTuneDaxis)





    if isStartStopExt||isBandwidthExt||isPhaseMarginExt||isSineAmpExt

        numLoops=0;

        if isTuneDaxis
            sigIdx_Daxis=1;
            numLoops=numLoops+1;
        else
            sigIdx_Daxis=1;
        end


        if isTuneQaxis
            sigIdx_Qaxis=numLoops+1;
            numLoops=numLoops+1;
        else
            sigIdx_Qaxis=1;
        end


        if isTuneSpeed
            sigIdx_Speed=numLoops+1;
            numLoops=numLoops+1;
        else
            sigIdx_Speed=1;
        end


        if isTuneFlux
            sigIdx_Flux=numLoops+1;
            numLoops=numLoops+1;
        else
            sigIdx_Flux=1;
        end
        sigIndexes=[sigIdx_Daxis,sigIdx_Qaxis,sigIdx_Speed,sigIdx_Flux];
    end


    pidBusStr='';
    ssBusStr='';
    if isTuneDaxis
        pidBusStr=horzcat(pidBusStr,'daxis_gains,');
        ssBusStr=horzcat(ssBusStr,'daxis,');
    end
    if isTuneQaxis
        pidBusStr=horzcat(pidBusStr,'qaxis_gains,');
        ssBusStr=horzcat(ssBusStr,'qaxis,');
    end
    if isTuneSpeed
        pidBusStr=horzcat(pidBusStr,'speed_gains,');
        ssBusStr=horzcat(ssBusStr,'speed,');
    end
    if isTuneFlux
        pidBusStr=horzcat(pidBusStr,'flux_gains,');
        ssBusStr=horzcat(ssBusStr,'flux,');
    end

    pidBusStr=pidBusStr(1:(end-1));
    ssBusStr=ssBusStr(1:(end-1));

    busPath=horzcat(blkPath,'/gains_bus');
    set_param(busPath,'OutputSignals',pidBusStr)

    busPath=horzcat(blkPath,'/startstop_bus');
    set_param(busPath,'OutputSignals',ssBusStr)


    inport_names={'PIDout_daxis','measured feedback_daxis','PIDout_qaxis','measured feedback_qaxis',...
    'PIDout_spd','measured feedback_spd','PIDout_flux','measured feedback_flux','startstop','ActiveLoop',...
    'bandwidth','target PM','sine Amp'};
    type_in_mask=[isTuneDaxis,isTuneDaxis,isTuneQaxis,isTuneQaxis...
    ,isTuneSpeed,isTuneSpeed,isTuneFlux,isTuneFlux,isStartStopExt,isStartStopExt...
    ,isBandwidthExt,isPhaseMarginExt,isSineAmpExt];

    AvailableBlocks=get_param(blkh,'Blocks');
    type_in_block=ismember(inport_names,AvailableBlocks);


    port=1;
    for k=1:length(type_in_mask)
        port=focautotuner.utilUpdateInport(blkPath,AvailableBlocks,type_in_mask,type_in_block,k,inport_names{k},port);
    end


    outport_names={'perturbation_daxis','perturbation_qaxis','perturbation_spd',...
    'perturbation_flux','pid gains','convergence','estimated PM',...
    'frd','nominal','loop startstops'};
    type_out_mask=[isTuneDaxis,isTuneQaxis,isTuneSpeed,isTuneFlux,true...
    ,true,isAchievedPMOut,isFRDOut,isU0Out,isActiveLoopOut];

    type_out_block=ismember(outport_names,AvailableBlocks);

    port=1;
    for k=1:length(type_out_mask)
        port=focautotuner.utilUpdateOutport(blkPath,AvailableBlocks,type_out_mask,type_out_block,k,outport_names{k},port);
    end



    if isStartStopExt
        set_param(blkh,'variantStartStop','variantExternal')
    else
        set_param(blkh,'variantStartStop','variantInternal')
    end


    if isBandwidthExt
        set_param(blkh,'variantBandwidth','variantExternal')
    else
        set_param(blkh,'variantBandwidth','variantInternal')
    end


    if isPhaseMarginExt
        set_param(blkh,'variantPhaseMargin','variantExternal')
    else
        set_param(blkh,'variantPhaseMargin','variantInternal')
    end


    if isSineAmpExt
        set_param(blkh,'variantSineAmplitudes','variantExternal')
    else
        set_param(blkh,'variantSineAmplitudes','variantInternal')
    end



    if isTuneDaxis
        set_param(blkh,'variantEnableDaxis','variantLoopEnabled')
    else
        set_param(blkh,'variantEnableDaxis','variantLoopDisabled')
    end


    if isTuneQaxis
        set_param(blkh,'variantEnableQaxis','variantLoopEnabled')
    else
        set_param(blkh,'variantEnableQaxis','variantLoopDisabled')
    end


    if isTuneSpeed
        set_param(blkh,'variantEnableSpeed','variantLoopEnabled')
    else
        set_param(blkh,'variantEnableSpeed','variantLoopDisabled')
    end


    if isTuneFlux
        set_param(blkh,'variantEnableFlux','variantLoopEnabled')
    else
        set_param(blkh,'variantEnableFlux','variantLoopDisabled')
    end


    IsNotUseTuningTs=strcmp(get_param(blkh,'UseTuningTs'),'off');
    TsTuning=slResolve(get_param(blkh,'TsTuning'),blkh);
    if(TsTuning==-1)||IsNotUseTuningTs
        set_param(blkh,'variantSingleMultiRate','SameSamplingRates')
        set_param(pidBlock,'NotDeployTuningModule','off')
    else
        set_param(blkh,'variantSingleMultiRate','DifferentSamplingRates')
        set_param(pidBlock,'NotDeployTuningModule','on')
    end


    if~isStartStopExt



        startTimeSpd=str2double(get_param(blkh,'StartTimeSpeed'));
        stopTimeSpd=startTimeSpd+str2double(get_param(blkh,'DurationSpeed'));


        startTimeFlux=str2double(get_param(blkh,'StartTimeFlux'));
        stopTimeFlux=startTimeFlux+str2double(get_param(blkh,'DurationFlux'));


        startTimeQaxis=str2double(get_param(blkh,'StartTimeQaxis'));
        stopTimeQaxis=startTimeQaxis+str2double(get_param(blkh,'DurationQaxis'));


        startTimeDaxis=str2double(get_param(blkh,'StartTimeDaxis'));
        stopTimeDaxis=startTimeDaxis+str2double(get_param(blkh,'DurationDaxis'));


        startTimes=[startTimeSpd,startTimeFlux,startTimeQaxis,startTimeDaxis];
        stopTimes=[stopTimeSpd,stopTimeFlux,stopTimeQaxis,stopTimeDaxis];
        startTimes=startTimes([isTuneSpeed,isTuneFlux,isTuneQaxis,isTuneDaxis]);
        stopTimes=stopTimes([isTuneSpeed,isTuneFlux,isTuneQaxis,isTuneDaxis]);
        for ii=1:length(startTimes)
            range=[startTimes(ii),stopTimes(ii)];
            check=any((startTimes>range(1))&(startTimes<=range(2)));
            if check
                error(getString(message('SLControllib:focautotuner:errSimultaneousTuning')));
            end
        end


        set_param(blkh,'StopTimeSpeed',num2str(stopTimeSpd));


        set_param(blkh,'StopTimeFlux',num2str(stopTimeFlux));


        set_param(blkh,'StopTimeQaxis',num2str(stopTimeQaxis));


        set_param(blkh,'StopTimeDaxis',num2str(stopTimeDaxis));
    end


    isUseSameSettingsInner=strcmp(blkObj.UseSameSettingsInner,'on')&&isTuneDaxis&&isTuneQaxis;
    if isUseSameSettingsInner

        focautotuner.utilSyncLoopSettings(blkh,'Current')
    end


    isUseSameSettingsOuter=strcmp(blkObj.UseSameSettingsOuter,'on')&&isTuneSpeed&&isTuneFlux;
    if isUseSameSettingsOuter

        focautotuner.utilSyncLoopSettings(blkh,'Outer')
    end


    params={'TsDaxis';'TsQaxis';'TsSpeed';'TsFlux'};
    variantParams={'variantValidDaxisSampleTime';'variantValidQaxisSampleTime';'variantValidSpeedSampleTime';'variantValidFluxSampleTime'};
    maskWSVars=get_param(blkh,'MaskWSVariables');
    maskNames={maskWSVars.Name};
    maskParamIdx=contains(maskNames,params);
    maskParamValues=[maskWSVars(maskParamIdx).Value];
    if~isempty(maskParamValues)
        for ii=1:length(maskParamValues)
            if maskParamValues(ii)==-1
                set_param(blkh,variantParams{ii},'variantInvalidTs')
            else
                set_param(blkh,variantParams{ii},'variantValidTs')
            end
        end
    end


    set_param([blkPath,'/PID Autotuner/Closed-Loop PID Autotuner'],'EstimationWindowSize',blkObj.EstimationWindowSize);

end

function localEnableTuningLoop(blkPath,gainStr,En)
    gainPath=horzcat(blkPath,'/Start Stop/StartStop Source/Internal Source/',gainStr);
    if En
        set_param(gainPath,'Gain','1')
    else
        set_param(gainPath,'Gain','0')
    end
end