function dnnfpgaRenderLrnBfpScalingOutput(gcb,kernelDataType,RoundingMode,PipelineLatency)

    if(isempty(kernelDataType))
        return;
    end

    if(isempty(PipelineLatency))
        return;
    end

    ssName='ssb';
    ssPath=[gcb,'/',ssName];
    ssPos=get_param(ssPath,'Position');

    try
        lh=get_param(ssPath,'LineHandles');
        delete_block(ssPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);

        InPort1='InData';
        InPort2='Scale';
        OutPort1='OutData';

        redrawScalingInsert(gcb,ssName,ssPos,kernelDataType,RoundingMode,PipelineLatency);

        add_line(gcb,[InPort1,'/1'],'ssb/1','autorouting','on');
        add_line(gcb,[InPort2,'/1'],'ssb/2','autorouting','on');
        add_line(gcb,'ssb/1',[OutPort1,'/1'],'autorouting','on');


    catch me
    end
end

function redrawScalingInsert(gcb,ssName,ssPos,kernelDataType,RoundingMode,PipelineLatency)
    root=fileparts([gcb,'/',ssName]);


    h=add_block('built-in/SubSystem',[gcb,'/',ssName],'MakeNameUnique','on','Position',ssPos,'TreatAsAtomicUnit','off');
    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];
    ssPosIn1=[320,533,350,547];
    ssPosIn2=[320,563,350,577];
    ssPosOut=[775,542,790,568];
    ssPosSwt1=[450,525,490,585];
    ssPosSwt2=[620,525,660,585];

    InPort1='InData';
    InPort2='Scale';
    OutPort1='OutData';

    add_block('built-in/InPort',[curGcb,'/',InPort1],'Position',ssPosIn1);
    add_block('built-in/InPort',[curGcb,'/',InPort2],'Position',ssPosIn2);
    add_block('built-in/OutPort',[curGcb,'/',OutPort1],'Position',ssPosOut);

    if(strcmp(kernelDataType,'single'))
        add_block('hdlsllib/Commonly Used Blocks/Delay',[curGcb,'/Delay'],'Position',ssPosSwt1);
        add_block('built-in/terminator',[curGcb,'/term1'],'Position',ssPosSwt2);
        set_param([curGcb,'/Delay'],'DelayLength','0')

        add_line(curGcb,[InPort1,'/1'],'Delay/1','autorouting','on');
        add_line(curGcb,'Delay/1',[OutPort1,'/1'],'autorouting','on');
        add_line(curGcb,[InPort2,'/1'],'term1/1','autorouting','on');

    else
        add_block('dnnfpgaBfpScalinglib/single2int8',[curGcb,'/ssb'],'Position',ssPosSwt1);

        set_param([curGcb,'/ssb'],'RoundingMode','RoundingMode');
        set_param([curGcb,'/ssb'],'PipelineLatency','PipelineLatency');

        add_block('hdlsllib/Commonly Used Blocks/Data Type Conversion',[curGcb,'/DTC'],'Position',ssPosSwt2);
        set_param([curGcb,'/DTC'],'OutDataTypeStr','int32')
        add_line(curGcb,[InPort1,'/1'],'ssb/1','autorouting','on');
        add_line(curGcb,[InPort2,'/1'],'ssb/2','autorouting','on');
        add_line(curGcb,'ssb/1','DTC/1','autorouting','on');
        add_line(curGcb,'DTC/1',[OutPort1,'/1'],'autorouting','on');
    end

end

