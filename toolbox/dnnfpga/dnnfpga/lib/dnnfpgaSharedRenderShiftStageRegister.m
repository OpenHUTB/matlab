function dnnfpgaSharedRenderShiftStageRegister(gcb,depth)



    if(isempty(depth))
        return;
    end
    if(depth<1)
        return;
    end
    portSpacer=90;
    outPortPosOrig=[340,58,370,72];
    ssrName='SSR';
    ssrPath=[gcb,'/',ssrName];
    pos=get_param(ssrPath,'Position');
    try
        lh=get_param(ssrPath,'LineHandles');
        delete_block(ssrPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        oldDepth=length(lh.Outport);
        for i=depth+1:oldDepth
            outPortName=['Out',num2str(i)];
            delete_block([gcb,'/',outPortName]);
        end
        for i=oldDepth+1:depth
            outPortPos=outPortPosOrig+(i-1)*[0,portSpacer,0,portSpacer];
            outPortName=['Out',num2str(i)];
            add_block('built-in/OutPort',[gcb,'/',outPortName],'Position',outPortPos);
        end
        redrawSSR(gcb,pos,depth);
        for i=1:depth
            outPortName=['Out',num2str(i)];
            add_line(gcb,[ssrName,'/',num2str(i)],[outPortName,'/1'],'autorouting','on');
        end
        add_line(gcb,'D/1',[ssrName,'/1'],'autorouting','on');
        add_line(gcb,'load/1',[ssrName,'/2'],'autorouting','on');
        add_line(gcb,'stage/1',[ssrName,'/3'],'autorouting','on');
    catch me
    end
end

function redrawSSR(curGcb,pos,depth)
    createRamSubsystem(pos,[curGcb,'/SSR'],depth);
end

function curGcb=createRamSubsystem(pos,curGcbOrig,depth)
    root=fileparts(curGcbOrig);


    h=add_block('built-in/SubSystem',curGcbOrig,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');
    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];
    dPortPos=[20,163,50,177];
    loadPortPos=[20,233,50,247];
    stagePortPos=[20,23,50,37];

    outputRegPos=[295,55,335,115];
    shiftRegPos=[110,155,150,215];
    regSpacer=185;


    add_block('built-in/InPort',[curGcb,'/D'],'Position',dPortPos);
    add_block('built-in/InPort',[curGcb,'/load'],'Position',loadPortPos);
    add_block('built-in/InPort',[curGcb,'/stage'],'Position',stagePortPos);

    for i=0:depth-1
        offset=[i*regSpacer,0,i*regSpacer,0];
        if(i==0)
            dPort='D/1';
        else
            dPort=['shiftReg',num2str(i),'/1'];
        end
        addRegisters(curGcb,num2str(i+1),shiftRegPos+offset,outputRegPos+offset,dPort,'load/1','stage/1');
    end

end

function addRegisters(curGcb,name,shiftRegPos,outputRegPos,dPort,loadPort,stagePort)

    outPortSize=[0,78,30,92];
    outPortPos=[outputRegPos(3)+20,outPortSize(2),outputRegPos(3)+20+outPortSize(3),outPortSize(4)];

    shiftRegName=['shiftReg',name];
    shiftRegPath=[curGcb,'/',shiftRegName];
    add_block('dnnfpgaSharedGenericlib/EnabledDelay',shiftRegPath,'Position',shiftRegPos);

    outputRegName=['outputReg',name];
    outputRegPath=[curGcb,'/',outputRegName];
    add_block('dnnfpgaSharedGenericlib/EnabledDelay',outputRegPath,'Position',outputRegPos);

    outPortName=['out',name];
    outPortPath=[curGcb,'/',outPortName];
    add_block('built-in/OutPort',outPortPath,'Position',outPortPos);

    add_line(curGcb,dPort,[shiftRegName,'/1'],'autorouting','on');
    add_line(curGcb,[shiftRegName,'/1'],[outputRegName,'/1'],'autorouting','on');
    add_line(curGcb,stagePort,[outputRegName,'/2'],'autorouting','on');
    add_line(curGcb,loadPort,[shiftRegName,'/2'],'autorouting','on');
    add_line(curGcb,[outputRegName,'/1'],[outPortName,'/1'],'autorouting','on');

end
