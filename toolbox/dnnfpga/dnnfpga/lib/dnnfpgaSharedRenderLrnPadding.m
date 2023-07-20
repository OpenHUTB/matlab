function dnnfpgaSharedRenderLrnPadding(gcb,tapLength)



    if(isempty(tapLength))
        return;
    end
    if(tapLength<1)
        return;
    end
    outPortPosOrig=[840,558,870,572];
    ssName='ssPadding';
    ssPath=[gcb,'/',ssName];
    pos=get_param(ssPath,'Position');
    try
        lh=get_param(ssPath,'LineHandles');
        delete_block(ssPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);

        inPortName2='InData';
        inPortName3='Idx';
        outPortName='OutData';



        outPortPos=outPortPosOrig;





        redrawTappedDelay(gcb,ssName,pos,tapLength);
        add_line(gcb,[inPortName2,'/1'],[ssName,'/1'],'autorouting','on');
        add_line(gcb,[inPortName3,'/1'],[ssName,'/2'],'autorouting','on');
        add_line(gcb,[ssName,'/1'],[outPortName,'/1'],'autorouting','on');

    catch me
    end
end

function redrawTappedDelay(curGcb,ssName,pos,tapLength)
    createPaddedSubsystem(pos,[curGcb,'/',ssName],tapLength);
end

function curGcb=createPaddedSubsystem(pos,curGcbOrig,tapLength)
    root=fileparts(curGcbOrig);


    h=add_block('built-in/SubSystem',curGcbOrig,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');
    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];
    InDataPortPos=[20,233,50,247];
    IdxPortPos=[20,323,50,337];

    outputRegPos=[905,155,925,195];
    shiftRegPos=[110,155,150,215];
    selRegPos=[60,420,150,520];
    regSpacer=185;


    add_block('built-in/InPort',[curGcb,'/InData'],'Position',InDataPortPos);
    add_block('built-in/InPort',[curGcb,'/Idx'],'Position',IdxPortPos);
    add_block('built-in/OutPort',[curGcb,'/OutData'],'Position',outputRegPos);
    add_block('built-in/Mux',[curGcb,'/Mux'],'Position',IdxPortPos+450);
    add_block('built-in/selector',[curGcb,'/selector'],'Position',selRegPos);

    set_param([curGcb,'/Mux'],'Inputs','tapLength');
    set_param([curGcb,'/selector'],'InputPortWidth','tapLength');
    set_param([curGcb,'/selector'],'IndexOptions','Index Vector (Port)');
    for i=1:tapLength-1
        offset=[i*regSpacer,0,i*regSpacer,0];
        add_block('dnnfpgaSharedGenericlib/ss1',[curGcb,'/ssPadIdx',num2str(i)],'Position',shiftRegPos+offset);
        set_param([curGcb,'/ssPadIdx',num2str(i)],'blockID',num2str(i));
        add_line(curGcb,'InData/1',['ssPadIdx',num2str(i),'/1'],'autorouting','on');
        add_line(curGcb,'Idx/1',['ssPadIdx',num2str(i),'/2'],'autorouting','on');
        add_line(curGcb,['ssPadIdx',num2str(i),'/1'],['Mux/',num2str(i+1)],'autorouting','on');
    end


    add_line(curGcb,'InData/1','selector/1','autorouting','on');
    add_line(curGcb,'Idx/1','selector/2','autorouting','on');
    add_line(curGcb,'selector/1','Mux/1','autorouting','on');
    add_line(curGcb,'Mux/1','OutData/1','autorouting','on');

end


