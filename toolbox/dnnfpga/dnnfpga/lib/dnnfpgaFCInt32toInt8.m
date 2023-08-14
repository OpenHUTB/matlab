function dnnfpgaFCInt32toInt8(gcb,kernelDataType,RoundingMode,PipelineLatency)
    if(isempty(kernelDataType))
        kernelDataType='single';
    end

    if(isempty(PipelineLatency))
        return;
    end

    ssName='QFC';
    ssPath=[gcb,'/',ssName];
    pos=get_param(ssPath,'Position');
    try
        lh=get_param(ssPath,'LineHandles');
        delete_block(ssPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        InPortName1='InData';
        InPortName2='Exp';
        OutPortName='OutData';

        redrawBusConnect(gcb,[gcb,'/',ssName],pos,kernelDataType,RoundingMode,PipelineLatency);
        add_line(gcb,[InPortName1,'/1'],[ssName,'/1'],'autorouting','on');
        add_line(gcb,[InPortName2,'/1'],[ssName,'/2'],'autorouting','on');
        add_line(gcb,[ssName,'/1'],[OutPortName,'/1'],'autorouting','on');

    catch
    end

    function redrawBusConnect(gcb,curGcbOrig,pos,kernelDataType,RoundingMode,PipelineLatency)
        root=fileparts(curGcbOrig);


        h=add_block('built-in/SubSystem',curGcbOrig,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');
        subBlockName=get_param(h,'name');
        curGcb=[root,'/',subBlockName];
        InDataPortPos=[110,103,140,117];
        IdxPortPos=[110,148,140,162];
        outputRegPos=[360,128,390,142];

        add_block('built-in/InPort',[curGcb,'/InData'],'Position',InDataPortPos);
        add_block('built-in/InPort',[curGcb,'/Exp'],'Position',IdxPortPos);
        add_block('built-in/OutPort',[curGcb,'/OutData'],'Position',outputRegPos);

        if(strcmp(kernelDataType,'single'))
            add_block('built-in/Delay',[curGcb,'/Delay'],'position',pos);
            add_block('built-in/Terminator',[curGcb,'/Terminate'],'position',IdxPortPos+100);
            set_param([curGcb,'/Delay'],'DelayLength','3*PipelineLatency');
            add_line(curGcb,'InData/1','Delay/1','autorouting','on');
            add_line(curGcb,'Delay/1','OutData/1','autorouting','on');
            add_line(curGcb,'Exp/1','Terminate/1','autorouting','on');
        else
            add_block('dnnfpgaBfpScalinglib/int322int8',[curGcb,'/DTC'],'position',pos);

            set_param([curGcb,'/DTC'],'RoundingMode','RoundingMode');
            set_param([curGcb,'/DTC'],'PipelineLatency','PipelineLatency');

            add_line(curGcb,'InData/1','DTC/1','autorouting','on');
            add_line(curGcb,'DTC/1','OutData/1','autorouting','on');
            add_line(curGcb,'Exp/1','DTC/2','autorouting','on');
        end

    end

end