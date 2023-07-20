function dnnfpgaLRNRenderlrnbus(gcb,opSize,lrnCompWindowSize,opRatio)
    if(isempty(opSize))
        return;
    end

    if(isempty(lrnCompWindowSize))
        return;
    end

    if(isempty(opRatio))
        return;
    end

    outPortPosOrig=[840,558,870,572];
    ssName='sslrnbus';
    ssPath=[gcb,'/',ssName];
    pos=get_param(ssPath,'Position');
    try
        lh=get_param(ssPath,'LineHandles');
        delete_block(ssPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);

        InPortName1='InData';
        InPortName2='Idx';
        outPortName='OutData';
        outPortPos=outPortPosOrig;

        redrawBusConnect(gcb,[gcb,'/',ssName],pos,opSize,lrnCompWindowSize,opRatio);
        add_line(gcb,[InPortName1,'/1'],[ssName,'/1'],'autorouting','on');
        add_line(gcb,[InPortName2,'/1'],[ssName,'/2'],'autorouting','on');
        add_line(gcb,[ssName,'/1'],[outPortName,'/1'],'autorouting','on');

    catch me
    end


end

function redrawBusConnect(gcb,curGcbOrig,pos,opSize,lrnCompWindowSize,opRatio)
    root=fileparts(curGcbOrig);


    h=add_block('built-in/SubSystem',curGcbOrig,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');
    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];
    InDataPortPos=[20,233,50,247];
    IdxPortPos=[20,323,50,337];
    outputRegPos=[905,155,925,195];
    selRegPos=[60,420,150,520];


    add_block('built-in/InPort',[curGcb,'/InData'],'Position',InDataPortPos);
    add_block('built-in/InPort',[curGcb,'/Idx'],'Position',IdxPortPos);
    add_block('built-in/OutPort',[curGcb,'/OutData'],'Position',outputRegPos);

    if(opRatio==1)
        add_block('built-in/Terminator',[curGcb,'/Terminate'],'Position',selRegPos);
        add_block('built-in/Delay',[curGcb,'/delay'],'Position',selRegPos);
        set_param([curGcb,'/delay'],'DelayLength',num2str(0));

        add_line(curGcb,'Idx/1','Terminate/1','autorouting','on');
        add_line(curGcb,'InData/1','delay/1','autorouting','on');
        add_line(curGcb,'delay/1','OutData/1','autorouting','on');
    else

        add_block('built-in/selector',[curGcb,'/selector'],'Position',selRegPos);
        add_block('simulink/Math Operations/Gain',[curGcb,'/gain1'],'Position',selRegPos+100);
        set_param([curGcb,'/selector'],'OutputSizes',num2str(lrnCompWindowSize));
        set_param([curGcb,'/gain1'],'Gain',num2str(lrnCompWindowSize));
        set_param([curGcb,'/gain1'],'ParamDataTypeStr','Inherit: Same as input');
        set_param([curGcb,'/gain1'],'OutDataTypeStr','Inherit: Inherit via back propagation');
        set_param([curGcb,'/selector'],'InputPortWidth','opSize');
        set_param([curGcb,'/selector'],'IndexOptions','Starting index (port)');
        set_param([curGcb,'/selector'],'IndexMode','Zero-based');
        add_line(curGcb,'InData/1','selector/1','autorouting','on');
        add_line(curGcb,'Idx/1','gain1/1','autorouting','on');
        add_line(curGcb,'gain1/1','selector/2','autorouting','on');
        add_line(curGcb,'selector/1','OutData/1','autorouting','on');


    end



end
