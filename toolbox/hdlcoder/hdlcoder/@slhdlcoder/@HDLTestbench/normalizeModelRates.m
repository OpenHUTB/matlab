function[sampleTime,minSampleTime]=normalizeModelRates(this)


    hcurrentdriver=hdlcurrentdriver;
    sampleTime=hcurrentdriver.PirInstance.getModelSampleTimes;
    minSampleTime=min(sampleTime(sampleTime>0));
    if isempty(minSampleTime)||minSampleTime<=0
        minSampleTime=1;
    end
    multiClockMode=hcurrentdriver.getParameter('clockinputs')==2;
    if multiClockMode
        clockScalingFactor=hcurrentdriver.PirInstance.getClockScalingFactor;
        if~isinf(clockScalingFactor)
            minSampleTime=minSampleTime/hcurrentdriver.PirInstance.getClockScalingFactor;
        end
    end


    this.InportSrc=normalizePorts(this,this.InportSrc,minSampleTime,multiClockMode);
    this.OutportSnk=normalizePorts(this,this.OutportSnk,minSampleTime,multiClockMode);
end

function portList=normalizePorts(this,portList,minSampleTime,multiClockMode)
    for jj=1:length(portList)
        normalizedST=floor(round(portList(jj).HDLSampleTime/minSampleTime));
        if isempty(normalizedST)
            error(message('hdlcoder:engine:EmptyTimeseries',portList(jj).loggingPortName));
        elseif normalizedST==0||isnan(portList(jj).SLSampleTime)
            normalizedST=1;
        end
        portList(jj).HDLSampleTime=normalizedST;
        if~multiClockMode
            portList(jj).ClockName=this.ClockName;
            portList(jj).ResetName=this.ResetName;
        else

            for ii=1:length(this.clockTable)
                if this.clockTable(ii).Ratio==portList(jj).HDLSampleTime
                    if this.clockTable(ii).Kind==0
                        portList(jj).ClockName=this.clockTable(ii).Name;
                    elseif this.clockTable(ii).Kind==1
                        portList(jj).ResetName=this.clockTable(ii).Name;
                    elseif this.clockTable(ii).Kind==2

                    end
                end
            end




            if hdlgetparameter('triggerasclock')&&...
                isempty(portList(jj).ClockName)
                for ii=1:length(this.clockTable)
                    if this.clockTable(ii).Ratio==minSampleTime&&...
                        this.clockTable(ii).Kind==0
                        portList(jj).ClockName=this.clockTable(ii).Name;
                        break;
                    end
                end
            end
        end
    end
end
