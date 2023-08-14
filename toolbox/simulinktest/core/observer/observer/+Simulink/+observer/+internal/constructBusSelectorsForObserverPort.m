function subsysPath=constructBusSelectorsForObserverPort(obsPortBlkHdl,busElems)










    assert(ishandle(obsPortBlkHdl));
    subsysPath=[];
    if isempty(busElems)
        return;
    end

    mdlH=bdroot(obsPortBlkHdl);
    mdlName=get_param(mdlH,'Name');

    portPos=get_param(obsPortBlkHdl,'Position');
    subsysPos=[portPos(1)+100,portPos(2),portPos(3)+100,portPos(4)];

    subsysPath=[mdlName,'/Selectors_',get_param(obsPortBlkHdl,'Name')];


    add_block('built-in/Subsystem',subsysPath,'Position',subsysPos);


    set_param(subsysPath,'TreatAsAtomicUnit','on');

    add_block('built-in/Inport',[subsysPath,'/In']);


    ph=get_param(obsPortBlkHdl,'PortHandles');
    oPort=ph.Outport;
    ph=get_param(subsysPath,'PortHandles');
    iPort=ph.Inport;
    add_line(mdlName,oPort,iPort);

    count=1;
    ph=get_param([subsysPath,'/In'],'PortHandles');
    srcPortH=ph.Outport;



    for i=1:length(busElems)
        if~isempty(busElems(i).name)
            srcPortH=addAndConfigureBusSelectorBlock(srcPortH,busElems(i).name,subsysPath,count);
            count=count+1;
        end

        if~isscalar(busElems(i).index)||busElems(i).index~=-1
            srcPortH=addAndConfigureSelectorBlock(srcPortH,busElems(i).index,subsysPath,count);
            count=count+1;
        end
    end


    addBlock(srcPortH,subsysPath,count,'built-in/Outport');

end

function outPortHdl=addAndConfigureBusSelectorBlock(srcPortHdl,name,parentPath,count)
    bsPath=addBlock(srcPortHdl,parentPath,count,'built-in/BusSelector');
    set_param(bsPath,'OutputSignals',name);
    ph=get_param(bsPath,'PortHandles');
    outPortHdl=ph.Outport;
end

function outPortHdl=addAndConfigureSelectorBlock(srcPortHdl,indexVec,parentPath,count)

    selPath=addBlock(srcPortHdl,parentPath,count,'built-in/Selector');

    len=length(indexVec);
    indexOptionArray=repelem("Index vector (dialog)",len);
    indexParamArray=string(indexVec);

    set_param(selPath,'NumberOfDimensions',num2str(len),...
    'IndexOptionArray',indexOptionArray.cellstr,...
    'IndexParamArray',indexParamArray.cellstr);

    ph=get_param(selPath,'PortHandles');
    outPortHdl=ph.Outport;
end

function newPath=addBlock(srcPortHdl,parentPath,count,blkToAdd)
    leftBlkPos=get_param(get_param(srcPortHdl,'Parent'),'Position');
    newBlkPos=[leftBlkPos(1)+100,leftBlkPos(2),leftBlkPos(3)+100,leftBlkPos(4)];
    newPath=[parentPath,'/S',num2str(count)];
    add_block(blkToAdd,newPath,'Position',newBlkPos);

    ph=get_param(newPath,'PortHandles');
    iPort=ph.Inport;
    add_line(parentPath,srcPortHdl,iPort);
end
