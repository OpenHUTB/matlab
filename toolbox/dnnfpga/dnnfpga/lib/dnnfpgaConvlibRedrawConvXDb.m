function dnnfpgaConvlibRedrawConvXDb(curGcb,pos,OpSize,ImgSize,FifoLength,Width)

    if(isempty(OpSize))
        add_block('dnnfpgaConvlib/PEb',curGcb,'Position',pos);
        return;
    end
    dimension=length(OpSize);
    OpLength=OpSize(end);
    ImgLength=fifoLength(OpSize,ImgSize);

    firstPePos=[240,51,335,169];
    peWidth=firstPePos(3)-firstPePos(1);
    pixelInPos=[25,58,55,72];
    resultInPos=[25,88,55,102];
    coefInPos=[25,118,55,132];
    coefLoadInPos=[25,148,55,162];
    modeInPos=[25,178,55,192];
    fifoLengthPos=[25,208,55,222];
    flDownPos=[120,208,160,222];
    flCurrPos=[120,238,160,252];
    fifoPos=[405,72,500,118];
    const1Pos=[380,87,390,103];
    pixelOutPos=[435,58,465,72];
    resultOutPos=[435,88,465,102];
    coefOutPos=[435,118,465,132];
    coefLoadOutPos=[435,148,465,162];
    modeOutPos=[435,178,465,192];

    add_block('built-in/SubSystem',curGcb,'Position',pos,'TreatAsAtomicUnit','off');
    add_block('built-in/InPort',[curGcb,'/pixelIn'],'Position',pixelInPos);
    add_block('built-in/InPort',[curGcb,'/resultIn'],'Position',resultInPos);
    add_block('built-in/InPort',[curGcb,'/coefIn'],'Position',coefInPos);
    add_block('built-in/InPort',[curGcb,'/coefLoad'],'Position',coefLoadInPos);
    add_block('built-in/InPort',[curGcb,'/modeIn'],'Position',modeInPos);
    add_block('built-in/InPort',[curGcb,'/fifoLength'],'Position',fifoLengthPos);
    if(FifoLength>0)
        add_block('built-in/Constant',[curGcb,'/const1'],'Position',const1Pos,'OutDataTypeStr','boolean','SampleTime','-1');
        add_block('dnnfpgaConvlib/DynamicDelay',[curGcb,'/FIFO'],'Position',fifoPos,'lengthLimit',sprintf('%d',FifoLength),'width',sprintf('%d',Width));
        add_block('built-in/Selector',[curGcb,'/flCurr'],'Position',flCurrPos,'IndexMode','Zero-based','Indices',sprintf('%d',dimension-1));
    else
        add_block('built-in/Terminator',[curGcb,'/flCurr'],'Position',flCurrPos);
    end
    if(dimension>1)
        add_block('built-in/Selector',[curGcb,'/flDown'],'Position',flDownPos,'IndexMode','Zero-based','Indices',sprintf('[0:%d]',dimension-2));
    end
    add_block('built-in/OutPort',[curGcb,'/pixelOut'],'Position',pixelOutPos);
    add_block('built-in/OutPort',[curGcb,'/resultOut'],'Position',resultOutPos);
    add_block('built-in/OutPort',[curGcb,'/coefOut'],'Position',coefOutPos);
    add_block('built-in/OutPort',[curGcb,'/coefLoadOut'],'Position',coefLoadOutPos);
    add_block('built-in/OutPort',[curGcb,'/modeOut'],'Position',modeOutPos);
    if(FifoLength>0)
        add_line(curGcb,'FIFO/1','resultOut/1');
    end

    if(OpLength==0)
        add_block('built-in/Terminator',[curGcb,'/pixelInTerm'],'Position',[pixelInPos(1)+100,pixelInPos(2),pixelInPos(3)+100,pixelInPos(4)]);
        add_block('built-in/Terminator',[curGcb,'/coefInTerm'],'Position',[coefInPos(1)+100,coefInPos(2),coefInPos(3)+100,coefInPos(4)]);
        add_block('built-in/Terminator',[curGcb,'/coefLoadTerm'],'Position',[coefLoadInPos(1)+100,coefLoadInPos(2),coefLoadInPos(3)+100,coefLoadInPos(4)]);
        add_block('built-in/Terminator',[curGcb,'/modeInTerm'],'Position',[modeInPos(1)+100,modeInPos(2),modeInPos(3)+100,modeInPos(4)]);
        pePos=[coefInPos(1)+100,0,coefInPos(3)+100,0];
        positionOutPorts(curGcb,pePos,peWidth,FifoLength>0);
        if(FifoLength>0)
            add_line(curGcb,'resultIn/1','FIFO/1','autorouting','on');
            add_line(curGcb,'const1/1','FIFO/2','autorouting','on');
            add_line(curGcb,'flCurr/1','FIFO/3','autorouting','on');
        else
            add_line(curGcb,'resultIn/1','resultOut/1','autorouting','on');
        end
        add_line(curGcb,'pixelIn/1','pixelInTerm/1','autorouting','on');
        add_line(curGcb,'coefIn/1','coefInTerm/1','autorouting','on');
        add_line(curGcb,'coefLoad/1','coefLoadTerm/1','autorouting','on');
        add_line(curGcb,'modeIn/1','modeInTerm/1','autorouting','on');
        add_line(curGcb,'fifoLength/1','flDown/1','autorouting','on');
        add_line(curGcb,'fifoLength/1','flCurr/1','autorouting','on');
    else
        lastPEName=sprintf('PE%d',OpLength-1);
        pePos=firstPePos;

        if(OpLength==1)
            fl=0;
        else
            fl=ImgLength;
        end
        dnnfpgaConvlibRedrawConvXDb([curGcb,'/PE0'],pePos,OpSize(1:end-1),ImgSize(1:end-1),fl,Width);

        add_line(curGcb,'pixelIn/1','PE0/1','autorouting','on');
        add_line(curGcb,'resultIn/1','PE0/2','autorouting','on');
        add_line(curGcb,'coefIn/1','PE0/3','autorouting','on');
        add_line(curGcb,'coefLoad/1','PE0/4','autorouting','on');
        add_line(curGcb,'modeIn/1','PE0/5','autorouting','on');
        add_line(curGcb,'fifoLength/1','flCurr/1','autorouting','on');
        if(dimension>1)
            add_line(curGcb,'fifoLength/1','flDown/1','autorouting','on');
            add_line(curGcb,'flDown/1','PE0/6','autorouting','on');
        end
        if(FifoLength>0)
            add_line(curGcb,'const1/1','FIFO/2','autorouting','on');
            add_line(curGcb,'flCurr/1','FIFO/3','autorouting','on');
        end
        for i=0:OpLength-2
            curPEName=sprintf('PE%d',i);
            nextPEName=sprintf('PE%d',i+1);
            pePos=pePos+[peWidth*2,0,peWidth*2,0];

            if(i==OpLength-2)
                fl=0;
            else
                fl=ImgLength;
            end
            dnnfpgaConvlibRedrawConvXDb([curGcb,'/',nextPEName],pePos,OpSize(1:end-1),ImgSize(1:end-1),fl,Width);
            add_line(curGcb,[curPEName,'/1'],[nextPEName,'/1'],'autorouting','on');
            add_line(curGcb,[curPEName,'/2'],[nextPEName,'/2'],'autorouting','on');
            add_line(curGcb,[curPEName,'/3'],[nextPEName,'/3'],'autorouting','on');
            add_line(curGcb,[curPEName,'/4'],[nextPEName,'/4'],'autorouting','on');
            add_line(curGcb,[curPEName,'/5'],[nextPEName,'/5'],'autorouting','on');
            if(dimension>1)
                add_line(curGcb,'flDown/1',[nextPEName,'/6'],'autorouting','on');
            end



        end
        positionOutPorts(curGcb,pePos,peWidth,FifoLength>0);
        add_line(curGcb,[lastPEName,'/1'],'pixelOut/1','autorouting','on');
        if(FifoLength>0)
            add_line(curGcb,[lastPEName,'/2'],'FIFO/1','autorouting','on');
        else
            add_line(curGcb,[lastPEName,'/2'],'resultOut/1','autorouting','on');
        end
        add_line(curGcb,[lastPEName,'/3'],'coefOut/1','autorouting','on');
        add_line(curGcb,[lastPEName,'/4'],'coefLoadOut/1','autorouting','on');
        add_line(curGcb,[lastPEName,'/5'],'modeOut/1','autorouting','on');
    end
end

function fl=fifoLength(OpSize,ImgSize)
    if(length(ImgSize)>1)
        fl=(ImgSize(end-1)-1)*prod(OpSize(1:end-2)+ImgSize(1:end-2)-1)+fifoLength(OpSize(1:end-1),ImgSize(1:end-1));
    else
        fl=0;
    end
end

function positionOutPorts(curGcb,pePos,peWidth,dealFifo)
    if(dealFifo)
        blkPos=get_param([curGcb,'/','const1'],'Position');
        blkPos=[pePos(1),blkPos(2),pePos(1)+blkPos(3)-blkPos(1),blkPos(4)]+[peWidth*2,0,peWidth*2,0];
        set_param([curGcb,'/','const1'],'Position',blkPos);
        blkPos=get_param([curGcb,'/','FIFO'],'Position');
        blkPos=[pePos(1),blkPos(2),pePos(1)+blkPos(3)-blkPos(1),blkPos(4)]+[peWidth*3,0,peWidth*3,0];
        set_param([curGcb,'/','FIFO'],'Position',blkPos);
    end
    blkPos=get_param([curGcb,'/','pixelOut'],'Position');
    blkPos=[pePos(1),blkPos(2),pePos(1)+blkPos(3)-blkPos(1),blkPos(4)]+[peWidth*5,0,peWidth*5,0];
    set_param([curGcb,'/','pixelOut'],'Position',blkPos);
    blkPos=get_param([curGcb,'/','resultOut'],'Position');
    blkPos=[pePos(1),blkPos(2),pePos(1)+blkPos(3)-blkPos(1),blkPos(4)]+[peWidth*5,0,peWidth*5,0];
    set_param([curGcb,'/','resultOut'],'Position',blkPos);
    blkPos=get_param([curGcb,'/','coefOut'],'Position');
    blkPos=[pePos(1),blkPos(2),pePos(1)+blkPos(3)-blkPos(1),blkPos(4)]+[peWidth*5,0,peWidth*5,0];
    set_param([curGcb,'/','coefOut'],'Position',blkPos);
    blkPos=get_param([curGcb,'/','coefLoadOut'],'Position');
    blkPos=[pePos(1),blkPos(2),pePos(1)+blkPos(3)-blkPos(1),blkPos(4)]+[peWidth*5,0,peWidth*5,0];
    set_param([curGcb,'/','coefLoadOut'],'Position',blkPos);
    blkPos=get_param([curGcb,'/','modeOut'],'Position');
    blkPos=[pePos(1),blkPos(2),pePos(1)+blkPos(3)-blkPos(1),blkPos(4)]+[peWidth*5,0,peWidth*5,0];
    set_param([curGcb,'/','modeOut'],'Position',blkPos);
end