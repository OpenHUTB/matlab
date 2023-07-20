function getClkrateAndLatency(this)




    hcurrentdriver=hdlcurrentdriver;


    tcinfo=hcurrentdriver.getTimingControllerInfo(0);
    this.clockTable=tcinfo.clockTable;


    fastestRatio=min(arrayfun(@(x)(x.Ratio),this.ClockTable));
    for ii=1:length(this.clockTable)
        if this.clockTable(ii).Ratio==fastestRatio
            if this.clockTable(ii).Kind==0
                this.ClockName=this.clockTable(ii).Name;
            elseif this.clockTable(ii).Kind==1
                this.ResetName=this.clockTable(ii).Name;
            elseif this.clockTable(ii).Kind==2
                this.ClockEnableName=this.clockTable(ii).Name;
            end
        end
    end



    for i=1:length(this.InportSrc)
        if this.InportSrc(i).SLPortHandle~=1
            this.InportSrc(i).dataRdEnb=this.ClockEnableName;
        end
    end
    modelSampleTime=this.normalizeModelRates;

    if isempty(tcinfo.topname)

        if this.isTBSingleRate('input/output')
            clkrate=1;
            tcPhase=1;
            tcRates=1;
            tcRatesOut=1;
        else



            dutTimingInfo.down=1;
            dutTimingInfo.offset=1;
            tcinfo.dutTimingInfo=dutTimingInfo;
            [clkrate,tcPhase,tcRates,tcRatesOut]=findClkRateAndPhase(this,...
            tcinfo,modelSampleTime);
        end
    else
        [clkrate,tcPhase,tcRates,tcRatesOut]=findClkRateAndPhase(this,...
        tcinfo,modelSampleTime);
    end



    if this.isIPTestbench
        latency=0;
    else
        latency=max(modelSampleTime);
    end



    if latency==0||((length(unique(modelSampleTime))==1)&&latency==Inf)
        latency=1;
    elseif latency==Inf
        sortedSampleTimes=sort(modelSampleTime,'descend');
        latency=sortedSampleTimes(2);
    end

    this.clkrate=clkrate;
    this.latency=latency;
    this.phaseVector=tcPhase;
    this.tbRates=tcRates;
    this.tbRatesOut=tcRatesOut;
end


function[count,phase,uniqueSampleTime,uniqueSampleTimeOut]=...
    findClkRateAndPhase(this,tcinfo,modelSampleTime)
    if isempty(this.InportSrc)
        uniqueSampleTime=unique(modelSampleTime);
    else
        uniqueSampleTime=unique(arrayfun(@(x)x.HDLSampleTime,this.InportSrc));
    end


    uniqueSampleTimeOut=unique(arrayfun(@(x)x.HDLSampleTime,this.OutportSnk));


    uniqueSampleTime=floor(round(uniqueSampleTime));
    uniqueSampleTimeOut=floor(round(uniqueSampleTimeOut));


    lengthUniqueSampleTime=length(uniqueSampleTime);
    lengthUniqueSampleTimeOut=length(uniqueSampleTimeOut);
    offset=ones(1,lengthUniqueSampleTime+lengthUniqueSampleTimeOut);
    down=[uniqueSampleTime,uniqueSampleTimeOut];

    p=pir;

    scalingFactor=p.getClockScalingFactor;
    if hdlgetparameter('clockinputs')==1
        down=floor(round(down.*scalingFactor));
    else


        down=floor(round(down./scalingFactor));
    end

    down=[down,tcinfo.dutTimingInfo.down];
    offset=[offset,tcinfo.dutTimingInfo.offset];

    tcController=hdlimplbase.TimingControllerHDLEmission;

    [count,phaseTC]=tcController.compute_tc_params(down,offset);

    phase=phaseTC(1:(numel(uniqueSampleTime)+numel(uniqueSampleTimeOut)))';
end


