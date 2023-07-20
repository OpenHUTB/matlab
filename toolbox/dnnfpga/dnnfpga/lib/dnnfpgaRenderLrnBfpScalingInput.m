function dnnfpgaRenderLrnBfpScalingInput(gcb,kernelDataType,PipelineLatency)

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
        InPort2='ResultData';
        InPort3='Sel';
        InPort4='Scale';
        OutPort1='OutData';

        redrawScalingInsert(gcb,ssName,ssPos,kernelDataType,PipelineLatency);

        add_line(gcb,[InPort1,'/1'],'ssb/1','autorouting','on');
        add_line(gcb,[InPort2,'/1'],'ssb/2','autorouting','on');
        add_line(gcb,[InPort3,'/1'],'ssb/3','autorouting','on');
        add_line(gcb,[InPort4,'/1'],'ssb/4','autorouting','on');
        add_line(gcb,'ssb/1',[OutPort1,'/1'],'autorouting','on');


    catch me
    end
end

function redrawScalingInsert(gcb,ssName,ssPos,kernelDataType,PipelineLatency)
    root=fileparts([gcb,'/',ssName]);


    h=add_block('built-in/SubSystem',[gcb,'/',ssName],'MakeNameUnique','on','Position',ssPos,'TreatAsAtomicUnit','off');
    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];
    ssPosIn=[20,233,50,247];
    ssPosOut=[905,155,925,195];
    ssPosSwt=[110,155,150,215];

    InPort1='InData';
    InPort2='ResultData';
    InPort3='Sel';
    InPort4='Scale';
    OutPort1='OutData';

    add_block('built-in/InPort',[curGcb,'/',InPort1],'Position',ssPosIn+300);
    add_block('built-in/InPort',[curGcb,'/',InPort2],'Position',ssPosIn+400);
    add_block('built-in/InPort',[curGcb,'/',InPort3],'Position',ssPosIn+500);
    add_block('built-in/InPort',[curGcb,'/',InPort4],'Position',ssPosIn+600);
    add_block('built-in/OutPort',[curGcb,'/',OutPort1],'Position',ssPosOut);

    if(strcmp(kernelDataType,'single'))
        add_block('hdlsllib/Signal Routing/Switch',[curGcb,'/switch'],'Position',ssPosSwt);
        add_block('built-in/terminator',[curGcb,'/term1'],'Position',ssPosSwt+200);
        set_param([curGcb,'/switch'],'Criteria','u2 ~= 0');

        add_line(curGcb,[InPort1,'/1'],'switch/3','autorouting','on');
        add_line(curGcb,[InPort3,'/1'],'switch/2','autorouting','on');
        add_line(curGcb,[InPort2,'/1'],'switch/1','autorouting','on');
        add_line(curGcb,[InPort4,'/1'],'term1/1','autorouting','on');
        add_line(curGcb,'switch/1',[OutPort1,'/1'],'autorouting','on');

    else
        add_block('dnnfpgaBfpScalinglib/int8toSingle',[curGcb,'/ssb'],'Position',ssPosSwt);
        add_block('built-in/terminator',[curGcb,'/term1'],'Position',ssPosSwt+200);
        add_block('built-in/terminator',[curGcb,'/term2'],'Position',ssPosSwt+400);
        set_param([curGcb,'/ssb'],'PipelineLatency','PipelineLatency');

        add_line(curGcb,[InPort1,'/1'],'ssb/1','autorouting','on');
        add_line(curGcb,[InPort4,'/1'],'ssb/2','autorouting','on');
        add_line(curGcb,[InPort2,'/1'],'term1/1','autorouting','on');
        add_line(curGcb,[InPort3,'/1'],'term2/1','autorouting','on');
        add_line(curGcb,'ssb/1',[OutPort1,'/1'],'autorouting','on');
    end

end

