function sampleTimeStr=setPortSampleTime(this,signal,hC,portHandle,isInTriggeredNet)



    sampleTimeStr='';
    if(isa(signal,'hdlcoder.signal'))
        if~isInTriggeredNet
            if strcmpi(this.SLEngineDebug,'on')&&hC.SimulinkHandle>0&&hC.isNetworkInstance
                sampleTimeStr=get_param(hC.SimulinkHandle,'SystemSampleTime');
            elseif strcmpi(this.SLEngineDebug,'on')&&hC.SimulinkHandle>0&&~hC.isCtxReference
                sampleTimeStr=get_param(hC.SimulinkHandle,'SampleTime');
            else
                sampleRate=signal.SimulinkRate;
                if isinf(sampleRate)
                    sampleTimeStr='-1';
                else
                    sampleTimeStr=sprintf('%16.15g',sampleRate);
                end
            end
            set_param(portHandle,'SampleTime',sampleTimeStr);
        end
    else
        set_param(portHandle,'SampleTime','-1');
    end
