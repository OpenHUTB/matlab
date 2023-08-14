function dnnfpgaSharedRenderReducer(gcb,width,blockType,delayLength)



    if(isempty(width))
        return;
    end
    reducerPath=[gcb,'/Reducer'];
    pos=get_param(reducerPath,'Position');
    try
        lh=get_param(reducerPath,'LineHandles');
        delete_block(reducerPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        redrawReducer(gcb,pos,width,blockType,delayLength);
    catch me %#ok<NASGU>
    end
end

function redrawReducer(gcb,pos,width,blockType,delayLength)

    inPortPos=[20,158,50,172];
    outPortPos=[410,293,440,307];
    selStartPos=[135,56,175,94];
    selSpacer=90;
    dmStartPos=[210,56,215,94];
    operatorStartPos=[270,56,315,94];
    muxPos=[355,22,360,22+width*selSpacer];


    subBlockName='Reducer';
    curGcb=[gcb,'/',subBlockName];
    add_block('built-in/SubSystem',curGcb,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');

    add_block('built-in/InPort',[curGcb,'/In'],'Position',inPortPos);
    add_block('built-in/OutPort',[curGcb,'/Out'],'Position',outPortPos);

    add_line(gcb,'In/1',[subBlockName,'/1'],'autorouting','on');
    add_line(gcb,[subBlockName,'/1'],'Out/1','autorouting','on');

    add_block('built-in/Mux',[curGcb,'/Mux'],'Position',muxPos,'Inputs',num2str(width));
    add_line(curGcb,'Mux/1','Out/1','autorouting','on');

    for i=0:width-1
        selPos=selStartPos+[0,selSpacer,0,selSpacer]*i;
        selName=sprintf('Sel%d',i);
        add_block('built-in/Selector',[curGcb,'/',selName],'Position',selPos,...
        'IndexMode','Zero-based','InputPortWidth',num2str(width^2),...
        'IndexParamArray',{sprintf('[%d:%d]',i*width,(i+1)*width-1)});
        dmPos=dmStartPos+[0,selSpacer,0,selSpacer]*i;
        dmName=sprintf('Demux%d',i);
        add_block('built-in/Demux',[curGcb,'/',dmName],'Position',dmPos,'Outputs',num2str(width));
        operatorPos=operatorStartPos+[0,selSpacer,0,selSpacer]*i;
        operatorName=sprintf('Operator%d',i);
        addOperatorTree(curGcb,operatorName,operatorPos,width,blockType,delayLength);
        for j=1:width
            add_line(curGcb,sprintf('%s/%d',dmName,j),sprintf('%s/%d',operatorName,j),'autorouting','on');
        end

        add_line(curGcb,'In/1',[selName,'/1'],'autorouting','on');
        add_line(curGcb,[selName,'/1'],[dmName,'/1'],'autorouting','on');
        add_line(curGcb,[operatorName,'/1'],['Mux/',num2str(i+1)],'autorouting','on');
    end
end

function addOperatorTree(gcb,name,pos,width,blockType,delayLength)
    lNum=ceil(log2(width));
    inPortPos=[-15,323,15,337];
    selStartPos=[135,56,175,94];
    verSpacer=90;
    herSpacer=90;
    outPortPos=[435,333,465,347];

    curGcb=[gcb,'/',name];
    add_block('built-in/SubSystem',curGcb,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');

    if(width==1)

        add_block('built-in/InPort',[curGcb,'/In'],'Position',inPortPos);
        add_block('built-in/OutPort',[curGcb,'/Out'],'Position',outPortPos);
        add_line(curGcb,'In/1','Out/1','autorouting','on');
        return;
    end

    upperHalf=2^(ceil(log2(width/2)));
    lowerHalf=width-upperHalf;
    st0Pos=[55,310,95,310]+[0,0,0,upperHalf*verSpacer];
    st1Pos=[55,st0Pos(4),95,st0Pos(4)]+[0,verSpacer,0,(lowerHalf+1)*verSpacer];
    operatorPos=[245,310,285,370];
    delayPos=[325,310,365,370];


    add_block(['built-in/',blockType],[curGcb,'/Operator'],'Position',operatorPos);
    add_block('built-in/Delay',[curGcb,'/Delay'],'Position',operatorPos+[herSpacer,0,herSpacer,0],'DelayLength',num2str(delayLength));
    add_line(curGcb,'Operator/1','Delay/1','autorouting','on');
    addOperatorTree(curGcb,'OperatorTree0',st0Pos,upperHalf,blockType,delayLength);
    addOperatorTree(curGcb,'OperatorTree1',st1Pos,lowerHalf,blockType,delayLength);
    stageDiff=ceil(log2(upperHalf))-ceil(log2(lowerHalf));
    if(stageDiff>0)
        add_block('built-in/Delay',[curGcb,'/MatchingDelay'],'Position',st1Pos+[herSpacer,0,herSpacer,0],'DelayLength',num2str(stageDiff*delayLength));
        add_line(curGcb,'OperatorTree1/1','MatchingDelay/1','autorouting','on');
        tree1Outport='MatchingDelay/1';
    else
        tree1Outport='OperatorTree1/1';
    end


    for i=0:upperHalf-1
        inPos=inPortPos+[0,verSpacer,0,verSpacer]*i;
        pName=['In',num2str(i)];
        add_block('built-in/InPort',[curGcb,'/',pName],'Position',inPos);
        add_line(curGcb,[pName,'/1'],sprintf('OperatorTree0/%d',i+1),'autorouting','on');
    end
    for i=0:lowerHalf-1
        inPos=inPortPos+[0,verSpacer,0,verSpacer]*(i+upperHalf);
        pName=['In',num2str(i+upperHalf)];
        add_block('built-in/InPort',[curGcb,'/',pName],'Position',inPos);
        add_line(curGcb,[pName,'/1'],sprintf('OperatorTree1/%d',i+1),'autorouting','on');
    end
    add_line(curGcb,'OperatorTree0/1','Operator/1','autorouting','on');
    add_line(curGcb,tree1Outport,'Operator/2','autorouting','on');
    add_block('built-in/OutPort',[curGcb,'/Out'],'Position',outPortPos);
    add_line(curGcb,'Delay/1','Out/1','autorouting','on');

end
