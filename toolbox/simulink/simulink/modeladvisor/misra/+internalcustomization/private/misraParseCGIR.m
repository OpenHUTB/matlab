







function parsedOutput=misraParseCGIR(node,system)

    switch node
    case 'NODE_SIGNED_BITOPS'
        parsedOutput=...
        Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults(...
        'NODE_SIGNED_BITOPS');
    case 'NODE_FCN_RECURSION'
        parsedOutput=...
        Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults(...
        'NODE_FCN_RECURSION');
    case 'NODE_SWITCH_DEFAULT'
        parsedOutput=getParsedOutputForSwitchDefault(system);
    case 'NODE_FLOAT_EQUALITY'
        parsedOutput=...
        Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults(...
        'NODE_FLOAT_EQUALITY');
    otherwise
        parsedOutput=[];
    end

end

function parsedOutput=getParsedOutputForSwitchDefault(system)



    blocks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','SwitchCase');
    filter=false(size(blocks));

    for i=1:numel(blocks)
        thisBlock=blocks{i};
        showDefaultCase=get_param(thisBlock,'ShowDefaultCase');
        if strcmp(showDefaultCase,'off')
            filter(i)=true;
        end
    end

    blocks=blocks(filter);

    if isempty(blocks)
        parsedOutput=[];
    else

        parsedOutput.tag=cell(1,numel(blocks));

        for index=1:numel(blocks)
            sid=Simulink.ID.getSID(blocks{index});
            tag.issue='NODE_SWITCH_DEFAULT';
            tag.sid=ModelAdvisor.Text(sid);
            tag.source='';
            tag.info=[];
            parsedOutput.tag{index}=tag;
        end

    end

end

function parsedOutput=getParsedOutputForFloatEquality(system)

    blocks1=analyzeDataTypeConversionBlocks(system);
    blocks2=analyzeSwitchBlocks(system);
    blocks3=analyzeRelationalOperatorBlocks(system);
    blocks=[blocks1;blocks2;blocks3];

    if isempty(blocks)
        parsedOutput=[];
    else

        parsedOutput.tag=cell(1,numel(blocks));

        for index=1:numel(blocks)
            sid=Simulink.ID.getSID(blocks{index});
            tag.issue='NODE_FLOAT_EQUALITY';
            tag.sid=ModelAdvisor.Text(sid);
            tag.source='';
            tag.info=[];
            parsedOutput.tag{index}=tag;
        end

    end

end

function blocks=analyzeDataTypeConversionBlocks(system)



    blocks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','DataTypeConversion');
    filter=false(size(blocks));

    for i=1:numel(blocks)
        thisBlock=blocks{i};
        portHandles=get_param(thisBlock,'PortHandles');
        is_U1_f=isPortFloating(system,portHandles,'Inport',1);
        is_Y1_b=isPortBoolean(system,portHandles,'Outport',1);
        if is_U1_f&&is_Y1_b
            filter(i)=true;
        end
    end

    blocks=blocks(filter);

end

function blocks=analyzeSwitchBlocks(system)



    blocks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','Switch');

    filter=false(size(blocks));

    for i=1:numel(blocks)
        thisBlock=blocks{i};
        criteria=get_param(thisBlock,'Criteria');
        if strcmp(criteria,'u2 ~= 0')
            portHandles=get_param(thisBlock,'PortHandles');
            is_U2_f=isPortFloating(system,portHandles,'Inport',2);
            if is_U2_f
                filter(i)=true;
            end
        end
    end

    blocks=blocks(filter);

end

function blocks=analyzeRelationalOperatorBlocks(system)



    blocks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','RelationalOperator');

    filter=false(size(blocks));

    for i=1:numel(blocks)
        thisBlock=blocks{i};
        operator=get_param(thisBlock,'Operator');
        if strcmp(operator,'==')||strcmp(operator,'~=')
            portHandles=get_param(thisBlock,'PortHandles');
            is_U1_f=isPortFloating(system,portHandles,'Inport',1);
            is_U2_f=isPortFloating(system,portHandles,'Inport',2);
            if is_U1_f||is_U2_f
                filter(i)=true;
            end
        end
    end

    blocks=blocks(filter);

end

function result=isPortBoolean(system,portHandles,port,index)
    typeString=getCompiledPortDataType(portHandles,port,index);
    baseType=getBaseType(system,typeString);
    category=getMisraEssentialTypeCategory(baseType);
    if strcmp(category,'boolean')
        result=true;ModelAdvisor.Text('Justified blocks');
    else
        result=false;
    end
end

function result=isPortFloating(system,portHandles,port,index)
    typeString=getCompiledPortDataType(portHandles,port,index);
    baseType=getBaseType(system,typeString);
    category=getMisraEssentialTypeCategory(baseType);
    if strcmp(category,'floating')
        result=true;
    else
        result=false;
    end
end

function type=getCompiledPortDataType(portHandles,port,index)
    switch port
    case 'Inport'
        type=get_param(portHandles.Inport(index),'CompiledPortDataType');
    case 'Outport'
        type=get_param(portHandles.Outport(index),'CompiledPortDataType');
    otherwise
        type='unknown';
    end
end

function baseType=getBaseType(system,typeString)
    cells=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,typeString);
    baseType=cells{1};
end

function category=getMisraEssentialTypeCategory(baseType)
    switch baseType
    case 'boolean',category='boolean';
    case{'double','single'},category='floating';
    case{'uint8','uint16','uint32'},category='unsigned';
    case{'int8','int16','int32'},category='signed';
    otherwise,category='unknown';
    end
end

