function isExpFcnStyle=convertToExportFunctionStyle(this)








    modelH=get_param(this.MdlName,'Handle');
    [needsConversion,isExpFcnStyle]=doesModelNeedConversion(modelH);
    if~needsConversion
        return;
    end

    [subSysH,triggerBlockH]=moveContentsIntoFcnCallSS(modelH);
    isCentralBlock=true;
    this.positionBlockInLayout(subSysH,isCentralBlock);
    this.positionBlockInLayout(triggerBlockH);

    fcnCallInportH=addAndConnectFcnCallInport(modelH,subSysH);
    this.positionBlockInLayout(fcnCallInportH);

    this.refreshModelLayout();

    isExpFcnStyle=true;
end

function[needsConversion,isExpFcnStyle]=doesModelNeedConversion(modelH)
    hasClientPorts=...
    ~isempty(autosar.simulink.functionPorts.Utils.findClientPorts(modelH));
    hasServerPorts=...
    ~isempty(autosar.simulink.functionPorts.Utils.findServerPorts(modelH));


    hasRateBasedLogic=...
    ~isempty(Simulink.findBlocksOfType(modelH,'Inport',Simulink.FindOptions('SearchDepth',1)))||...
    ~isempty(Simulink.findBlocksOfType(modelH,'Outport',Simulink.FindOptions('SearchDepth',1)))||...
    hasClientPorts;
    hasFcnPorts=hasClientPorts||hasServerPorts;
    needsConversion=hasFcnPorts&&hasRateBasedLogic;


    isExpFcnStyle=~hasRateBasedLogic;
    assert(~(needsConversion&&isExpFcnStyle),...
    'Model cannot require conversion if it already export function style')
end

function[subSysH,triggerBlockH]=moveContentsIntoFcnCallSS(modelH)

    blocks=Simulink.findBlocks(modelH,Simulink.FindOptions('SearchDepth',1));

    serverFunctions=Simulink.findBlocks(modelH,'BlockType',...
    'SubSystem','IsSimulinkFunction','on');
    fcnPortBlocks=Simulink.findBlocks(modelH,'IsClientServer','on');
    blocks=setdiff(blocks,serverFunctions);
    blocks=setdiff(blocks,fcnPortBlocks);


    Simulink.BlockDiagram.createSubSystem(blocks);
    subSysH=find_system(modelH,'SearchDepth',1,'BlockType',...
    'SubSystem','IsSimulinkFunction','off');
    if~(isempty(subSysH))
        set_param(subSysH,'Name',[get_param(modelH,'Name'),'_triggered_sys']);

        triggerBlockH=add_block('built-in/TriggerPort',...
        [getfullname(subSysH),'/','step'],...
        'TriggerType','function-call',...
        'StatesWhenEnabling','held',...
        'MakeNameUnique','on');
    else
        triggerBlockH=[];
    end
end

function fcnCallInport=addAndConnectFcnCallInport(modelH,subSysH)

    if isempty(subSysH)
        fcnCallInport=[];
        return;
    end
    fcnCallInport=add_block('built-in/Inport',...
    [getfullname(modelH),'/step'],...
    'OutputFunctionCall','on','MakeNameUnique','on');
    dstBlock=[get_param(subSysH,'Name'),'/trigger'];
    autosar.mm.mm2sl.layout.LayoutHelper.addLine(modelH,...
    [get_param(fcnCallInport,'Name'),'/1'],dstBlock);
end
