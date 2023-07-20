function iconstr=utilGetMaskDisplayString(blkh)





    blkObj=get_param(blkh,'Object');
    focshared(blkh);


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

    Title="fprintf('Field Oriented Control\n\nAutotuner');";
    portIn=1;
    portOut=1;
    inportStr="port_label('input',";
    outportStr="port_label('output',";


    inPorts=find_system(blkh,'SearchDepth',1,'LookUnderMasks','on','followlinks','on','BlockType','Inport');
    inPortNames=get_param(inPorts,'Name');



    if isTuneDaxis&&any(strcmp(inPortNames,'PIDout_daxis'))
        InDaxis=strcat(inportStr,num2str(portIn),", 'PIDout daxis');");
        InDaxis=strcat(InDaxis,inportStr,num2str(portIn+1),", 'measured feedback daxis');");
        OutDaxis=strcat(outportStr,num2str(portOut),", 'perturbation daxis');");
        portIn=portIn+2;
        portOut=portOut+1;
    else
        InDaxis=[];
        OutDaxis=[];
    end


    if isTuneQaxis&&any(strcmp(inPortNames,'PIDout_qaxis'))
        InQaxis=strcat(inportStr,num2str(portIn),", 'PIDout qaxis');");
        InQaxis=strcat(InQaxis,inportStr,num2str(portIn+1),", 'measured feedback qaxis');");
        OutQaxis=strcat(outportStr,num2str(portOut),", 'perturbation qaxis');");
        portIn=portIn+2;
        portOut=portOut+1;
    else
        InQaxis=[];
        OutQaxis=[];
    end


    if isTuneSpeed&&any(strcmp(inPortNames,'PIDout_spd'))
        InSpeed=strcat(inportStr,num2str(portIn),", 'PIDout spd');");
        InSpeed=strcat(InSpeed,inportStr,num2str(portIn+1),", 'measured feedback spd');");
        OutSpeed=strcat(outportStr,num2str(portOut),", 'perturbation speed');");
        portIn=portIn+2;
        portOut=portOut+1;
    else
        InSpeed=[];
        OutSpeed=[];
    end


    if isTuneFlux&&any(strcmp(inPortNames,'PIDout_flux'))
        InFlux=strcat(inportStr,num2str(portIn),", 'PIDout flux');");
        InFlux=strcat(InFlux,inportStr,num2str(portIn+1),", 'measured feedback flux');");
        OutFlux=strcat(outportStr,num2str(portOut),", 'perturbation flux');");
        portIn=portIn+2;
        portOut=portOut+1;
    else
        InFlux=[];
        OutFlux=[];
    end




    if isStartStopExt&&any(strcmp(inPortNames,'startstop'))
        InStartStop=strcat(inportStr,num2str(portIn),", 'startstop');");
        InStartStop=strcat(InStartStop,inportStr,num2str(portIn+1),", 'ActiveLoop');");
        portIn=portIn+2;
    else
        InStartStop=[];
    end


    if isBandwidthExt&&any(strcmp(inPortNames,'bandwidth'))
        InWC=strcat(inportStr,num2str(portIn),", 'bandwidth');");
        portIn=portIn+1;
    else
        InWC=[];
    end


    if isPhaseMarginExt&&any(strcmp(inPortNames,'target PM'))
        InPM=strcat(inportStr,num2str(portIn),", 'target PM');");
        portIn=portIn+1;
    else
        InPM=[];
    end


    if isSineAmpExt&&any(strcmp(inPortNames,'sine Amp'))
        InSineAmp=strcat(inportStr,num2str(portIn),", 'sine Amp');");
        portIn=portIn+1;
    else
        InSineAmp=[];
    end



    outPorts=find_system(blkh,'SearchDepth',1,'LookUnderMasks','on','followlinks','on','BlockType','Outport');
    outPortNames=get_param(outPorts,'Name');


    OutGains=strcat(outportStr,num2str(portOut),", 'pid gains');");
    portOut=portOut+1;


    OutConvergence=strcat(outportStr,num2str(portOut),", 'convergence');");
    portOut=portOut+1;


    if isAchievedPMOut&&any(strcmp(outPortNames,'estimated PM'))
        OutEstPM=strcat(outportStr,num2str(portOut),", 'estimated PM');");
        portOut=portOut+1;
    else
        OutEstPM=[];
    end


    if isFRDOut&&any(strcmp(outPortNames,'frd'))
        OutFRD=strcat(outportStr,num2str(portOut),", 'frd');");
        portOut=portOut+1;
    else
        OutFRD=[];
    end


    if isU0Out&&any(strcmp(outPortNames,'nominal'))
        OutNominal=strcat(outportStr,num2str(portOut),", 'nominal');");
        portOut=portOut+1;
    else
        OutNominal=[];
    end


    if isActiveLoopOut&&any(strcmp(outPortNames,'loop startstops'))
        OutStartStop=strcat(outportStr,num2str(portOut),", 'loop startstops');");
        portOut=portOut+1;
    else
        OutStartStop=[];
    end


    maskdisplay=strcat(Title,InDaxis,InQaxis,InSpeed,InFlux,InStartStop,InWC,InPM,InSineAmp,...
    OutDaxis,OutQaxis,OutSpeed,OutFlux,OutGains,OutConvergence,OutEstPM,OutFRD,OutNominal,OutStartStop);
    iconstr=maskdisplay;
