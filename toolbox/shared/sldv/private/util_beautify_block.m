function util_beautify_block(block)




    block=getfullname(block);

    blockType=get_param(block,'BlockType');



    if contains(blockType,{'SubSystem'})
        beautifySubsystemBlockSize(block);
    elseif contains(blockType,{'ArgIn','ArgOut'})
        beautifyArgumentBlockSize(block);
    end
end



function beautifySubsystemBlockSize(block)

    minWidth=200;
    minHeight=100;
    fontSize=10;
    maxInportName=0;
    maxOutportName=0;

    sysName=block;
    findOpts=Simulink.FindOptions("SearchDepth",1);
    inports=Simulink.findBlocksOfType(sysName,'Inport',findOpts);
    outports=Simulink.findBlocksOfType(sysName,'Outport',findOpts);

    inportPortNames=arrayfun(@(in)get_param(in,'PortName'),inports,'UniformOutput',false);
    numInports=numel(inportPortNames);
    for idx=1:numInports
        blkName=inportPortNames{idx};
        maxInportName=max(maxInportName,length(blkName));
    end

    outportPortNames=arrayfun(@(out)get_param(out,'PortName'),outports,'UniformOutput',false);
    numOutports=numel(outportPortNames);
    for idx=1:numOutports
        blkName=outportPortNames{idx};
        maxOutportName=max(maxOutportName,length(blkName));
    end

    currentPosition=get_param(block,'Position');


    x=currentPosition(1);
    y=currentPosition(2);




    if y>32000
        x=x+150;
        y=33;
    end

    simFunPrototypeLen=0;
    simFunVisibilityLen=0;
    triggerPort=Simulink.findBlocksOfType(sysName,'TriggerPort',findOpts);
    if~isempty(triggerPort)
        triggerPort=triggerPort(1);
        isSimFunc=get_param(triggerPort,'IsSimulinkFunction');
        if strcmp(isSimFunc,'on')
            funcPrototype=get_param(triggerPort,'FunctionPrototype');
            simFunPrototypeLen=length(funcPrototype);
            funVisibilityText=get_param(triggerPort,'FunctionVisibility');




            if strcmp(funVisibilityText,'global')



                if(numel(inports)>1)&&(numel(outports)>1)




                    simFunVisibilityLen=15;
                elseif(numel(inports)>1)||(numel(outports)>1)
                    simFunVisibilityLen=30;
                end
            end
        end
    end


    textLength=max(simFunPrototypeLen,maxInportName+maxOutportName+simFunVisibilityLen);
    w=0.6*fontSize*textLength;
    h=(max(numInports,numOutports)+1)*35+30;


    w=max(w,minWidth);
    h=max(h,minHeight);


    newPos=[x,y,x+w,y+h];
    set_param(block,'Position',newPos);
end


function beautifyArgumentBlockSize(block)

    fontSize=10;
    scalingConstant=0.7;

    currentPos=get_param(block,'Position');

    text=get_param(block,'ArgumentName');
    w=max(40,scalingConstant*fontSize*length(text));
    newPos=[currentPos(1),currentPos(2),(currentPos(1)+w+10),(currentPos(2)+20)];


    set_param(block,'Position',newPos);



    set_param(block,'ShowName','off');
end

