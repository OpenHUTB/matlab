function dnnfpgaRenderOutputProcPath(gcb,kernelDataType,RoundingMode,PipelineLatency)

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

        InPort1='InA';
        InPort2='InB';
        InPort3='I2Iexp';
        OutPort1='OutA';
        OutPort2='OutB';

        redrawScalingInsert(gcb,ssName,ssPos,kernelDataType,RoundingMode,PipelineLatency);

        add_line(gcb,[InPort1,'/1'],'ssb/1','autorouting','on');
        add_line(gcb,[InPort2,'/1'],'ssb/2','autorouting','on');
        add_line(gcb,[InPort3,'/1'],'ssb/3','autorouting','on');
        add_line(gcb,'ssb/1',[OutPort1,'/1'],'autorouting','on');
        add_line(gcb,'ssb/2',[OutPort2,'/1'],'autorouting','on');


    catch me
    end
end

function redrawScalingInsert(gcb,ssName,ssPos,kernelDataType,RoundingMode,PipelineLatency)
    root=fileparts([gcb,'/',ssName]);


    h=add_block('built-in/SubSystem',[gcb,'/',ssName],'MakeNameUnique','on','Position',ssPos,'TreatAsAtomicUnit','off');
    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];
    ssPosIn=[20,233,50,247];
    ssPosOut=[905,233,925,247];
    ssPosSwt=[110,155,150,215];

    InPort1='InA';
    InPort2='InB';
    InPort3='I2Iexp';
    OutPort1='OutA';
    OutPort2='OutB';

    add_block('built-in/InPort',[curGcb,'/',InPort1],'Position',ssPosIn);
    add_block('built-in/InPort',[curGcb,'/',InPort2],'Position',ssPosIn+100);
    add_block('built-in/InPort',[curGcb,'/',InPort3],'Position',ssPosIn+200);
    add_block('built-in/OutPort',[curGcb,'/',OutPort1],'Position',ssPosOut);
    add_block('built-in/OutPort',[curGcb,'/',OutPort2],'Position',ssPosOut+200);

    if(strcmp(kernelDataType,'single'))
        add_block('built-in/terminator',[curGcb,'/term1'],'Position',ssPosSwt+300);

        add_line(curGcb,[InPort1,'/1'],[OutPort1,'/1'],'autorouting','on');
        add_line(curGcb,[InPort2,'/1'],[OutPort2,'/1'],'autorouting','on');
        add_line(curGcb,[InPort3,'/1'],'term1/1','autorouting','on');

    else
        add_block('dnnfpgaBfpScalinglib/int322int8',[curGcb,'/ssb'],'Position',ssPosSwt);
        add_block('dnnfpgaBfpScalinglib/int322int8',[curGcb,'/ssb1'],'Position',ssPosSwt+300);

        set_param([curGcb,'/ssb'],'RoundingMode','RoundingMode');
        set_param([curGcb,'/ssb'],'PipelineLatency','PipelineLatency');
        set_param([curGcb,'/ssb1'],'RoundingMode','RoundingMode');
        set_param([curGcb,'/ssb1'],'PipelineLatency','PipelineLatency');

        add_line(curGcb,[InPort1,'/1'],'ssb/1','autorouting','on');
        add_line(curGcb,[InPort2,'/1'],'ssb1/1','autorouting','on');
        add_line(curGcb,[InPort3,'/1'],'ssb/2','autorouting','on');
        add_line(curGcb,[InPort3,'/1'],'ssb1/2','autorouting','on');

        add_line(curGcb,'ssb/1',[OutPort1,'/1'],'autorouting','on');
        add_line(curGcb,'ssb1/1',[OutPort2,'/1'],'autorouting','on');

    end

end

