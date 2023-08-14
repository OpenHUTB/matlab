

function globalFlag=checkNFPLatency(this)



    globalFlag=true;
    model=this.m_sys;
    dut=this.m_DUT;
    message_summary=DAStudio.message('HDLShared:hdlmodelchecker:latencyCheckReportSummary');

    globalLatencyStrategy='Max';
    targetConfigNFP=false;

    targetConfig=hdlget_param(model,'FloatingPointTargetConfig');
    if~isempty(targetConfig)&&strcmpi('NativeFloatingPoint',targetConfig.Library)


        globalLatencyStrategy=targetConfig.LibrarySettings.LatencyStrategy;
        targetConfigNFP=true;
    end

    blocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'RegExp','On','Type','Block');
    for i=1:numel(blocks)


        [reqLatency,minLat,maxLat,flag,msgId]=hdlcoder.ModelChecker.getRequiredLatency(blocks{i},globalLatencyStrategy,targetConfigNFP);

        if~flag
            this.addCheck('message',message_summary,blocks{i},0,DAStudio.message(msgId,get_param(blocks{i},'Name')));
            this.setLatency(reqLatency);
            globalFlag=false;
            continue;
        end

        if(reqLatency==0)
            continue;
        end

        srcBlkPortHandles=get_param(blocks{i},'PortHandles');
        inputPipelineDelays=0;
        outputPipelineDelays=hdlget_param(blocks{i},'outputpipeline');
        if(outputPipelineDelays>0)
            if(outputPipelineDelays>=reqLatency)
                continue;
            end
            this.addCheck('message',message_summary,blocks{i},0,DAStudio.message('HDLShared:hdlmodelchecker:desc_NFP_latency_with_outputpipeline',get_param(blocks{i},'Name'),reqLatency,outputPipelineDelays));
            this.setLatency(reqLatency);
            globalFlag=false;
            continue;
        end
        existingDesignDelay=0;

        for k=1:length(srcBlkPortHandles.Outport)
            srcBlkOutportLineHandle=get_param(srcBlkPortHandles.Outport(k),'Line');

            dstBlkHandles=get_param(srcBlkOutportLineHandle,'DstBlockHandle');
            if(length(dstBlkHandles)==1)
                if(strcmp(get_param(dstBlkHandles,'BlockType'),'Delay'))
                    if strcmpi(get_param(dstBlkHandles,'ShowEnablePort'),'on')||...
                        ~strcmpi(get_param(dstBlkHandles,'ExternalReset'),'None')
                        existingDesignDelay=0;
                    else
                        existingDesignDelay=min(inf,str2num(get_param(dstBlkHandles,'DelayLength')));
                    end
                else
                    try
                        inputPipelineDelays=hdlget_param([get_param(blocks{i},'Parent'),'/',get_param(dstBlkHandles,'Name')],'inputpipeline');

                    catch


                        inputPipelineDelays=0;
                    end
                end
            else
                existingDesignDelay=0;
            end
        end

        if(inputPipelineDelays>0)&&...
            (existingDesignDelay==0)

            if(reqLatency>inputPipelineDelays)
                this.addCheck('message',message_summary,blocks{i},0,...
                DAStudio.message('HDLShared:hdlmodelchecker:desc_NFP_latency_with_inputpipeline',get_param(blocks{i},'Name'),reqLatency,inputPipelineDelays));
                this.setLatency(reqLatency);
                globalFlag=false;
            end
        else

            reqDelay=reqLatency-existingDesignDelay;
            if(reqDelay>0)
                if(existingDesignDelay==0)
                    msg=DAStudio.message('HDLShared:hdlmodelchecker:desc_latency_without_delay',get_param(blocks{i},'Name'),reqLatency);
                else
                    msg=DAStudio.message('HDLShared:hdlmodelchecker:desc_latency_with_delay',get_param(blocks{i},'Name'),reqLatency,existingDesignDelay);
                end
                this.addCheck('message',message_summary,blocks{i},0,msg);
                this.setLatency(reqLatency);
                globalFlag=false;
            end
        end
    end

end




