function[msgobj,level,val]=validateAndSetNetworkParam(subsysImplParam,blockPath,network,checkSampleTime)









    if nargin<4
        checkSampleTime=false;
    end

    if nargin<3
        paramCheckingOnly=true;
        network=[];
    else
        paramCheckingOnly=false;
    end

    msgobj='';
    level='';

    switch lower(subsysImplParam{1})
    case 'outputpipeline'
        val=subsysImplParam{2};
        if(val>0)&&~paramCheckingOnly
            network.setOutputPipeline(val);
        elseif(val<0)
            msgobj=message('hdlcoder:engine:invalidOutputPipeline',blockPath);
            level='Error';
        end
    case 'constrainedoutputpipeline'
        val=subsysImplParam{2};
        if(val>0)&&~paramCheckingOnly
            network.setConstrainedOutputPipeline(val);
        elseif(val<0)
            msgobj=message('hdlcoder:engine:invalidConstrainedOutputPipeline',...
            blockPath);
            level='Error';
        end

    case 'inputpipeline'
        val=subsysImplParam{2};
        if(val>0)&&~paramCheckingOnly
            network.setInputPipeline(val);
        elseif(val<0)
            msgobj=message('hdlcoder:engine:invalidInputPipeline',blockPath);
            level='Error';
        end

    case 'distributedpipelining'
        val=subsysImplParam{2};
        if~strcmpi(val,'on')&&~strcmpi(val,'off')&&~strcmpi(val,'inherit')
            msgobj=message('hdlcoder:engine:invalidDistributedPipelining',blockPath);
            level='Error';
        end

        if~paramCheckingOnly
            network.setDistributedPipeliningFromString(val);
        end
    case 'sharingfactor'
        val=subsysImplParam{2};
        if~isnumeric(val)||(val<0||floor(val)~=val)
            msgobj=message('hdlcoder:engine:invalidSharingFactor',blockPath);
            level='Error';
        elseif val>0&&~paramCheckingOnly
            network.setSharingFactor(val);

            if(checkSampleTime)
                sst=get_param(blockPath,'SystemSampleTime');
                if~strcmpi(sst,'-1')
                    msgobj=message('hdlcoder:engine:invalidSharingST');
                    level='Error';
                end
            end
        end

    case 'flattenhierarchy'
        val=subsysImplParam{2};
        if~strcmpi(val,'on')&&~strcmpi(val,'off')&&~strcmpi(val,'inherit')
            msgobj=message('hdlcoder:engine:invalidFlattenHierarchy',blockPath);
            level='Error';
        end
        if~paramCheckingOnly
            network.setFlattenHierarchy(val);
        end

    case 'adaptivepipelining'
        val=subsysImplParam{2};
        if~strcmpi(val,'on')&&~strcmpi(val,'off')&&~strcmpi(val,'inherit')
            msgobj=message('hdlcoder:engine:invalidHardwareMode',blockPath);
            level='Error';
        end
        if~paramCheckingOnly
            network.setHardwareMode(val);
        end

    case 'clockratepipelining'
        val=subsysImplParam{2};
        if~strcmpi(val,'on')&&~strcmpi(val,'off')&&~strcmpi(val,'inherit')
            msgobj=message('hdlcoder:engine:invalidClockRatePipelining',blockPath);
            level='Error';
        end
        if~paramCheckingOnly
            network.setLocalClockRatePipelining(val);
        end

    case 'balancedelays'
        val=subsysImplParam{2};
        if~strcmpi(val,'on')&&~strcmpi(val,'off')&&~strcmpi(val,'inherit')
            msgobj=message('hdlcoder:engine:invalidDelayBalancing',blockPath);
            level='Error';
        end
        if~paramCheckingOnly
            network.setDelayBalancing(val);
        end

    case 'streamingfactor'
        val=subsysImplParam{2};
        if~isnumeric(val)||(val<0||floor(val)~=val)
            msgobj=message('hdlcoder:engine:invalidStreamingFactor',blockPath);
            level='Error';
        elseif val>0&&~paramCheckingOnly
            network.setStreamingFactor(val);
            if(checkSampleTime)
                sst=get_param(blockPath,'SystemSampleTime');
                if~strcmpi(sst,'-1')
                    msgobj=message('hdlcoder:engine:invalidStreamingST');
                    level='Error';
                end
            end
        end

    case 'dspstyle'
        dspModeStr=subsysImplParam{2};
        val=int8(0);

        if strcmpi(dspModeStr,'on')
            val=int8(1);
            hDriver=hdlcurrentdriver;
            synthesisToolname=hDriver.getParameter('SynthesisTool');
            if~(strcmpi(synthesisToolname,'Xilinx ISE')||...
                strcmpi(synthesisToolname,'Altera Quartus II')||...
                strcmpi(synthesisToolname,'Xilinx Vivado'))
                msgobj=message('hdlcoder:validate:DSPStyleNoSynthesisTool');
                level='Warning';
                val=int8(0);
            end
        elseif strcmpi(dspModeStr,'off')
            val=int8(2);
        end
        if~paramCheckingOnly
            network.setMultStyle(val);
        end
    otherwise
        val=[];
    end
end

