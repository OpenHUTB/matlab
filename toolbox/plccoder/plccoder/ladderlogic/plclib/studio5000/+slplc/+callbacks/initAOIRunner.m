function initAOIRunner(block)



    blockFullName=getfullname(block);
    aoiRunnerLogicBlock=slplc.utils.getInternalBlockPath(blockFullName,'Logic');
    aoiBlocks=plc_find_system(aoiRunnerLogicBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'PLCPOUType','Function Block');

    if isempty(aoiBlocks)
        slplc.utils.setVariableList(block,[]);
        return
    end

    assert(numel(aoiBlocks)==1,...
    'slplc:invalidAOIRunner','Only one AOI block is allowed in the AOI Runner Block');

    aoiBlock=aoiBlocks{1};
    aoiVarList=slplc.utils.getVariableList(aoiBlock);
    set_param(aoiBlock,'Priority','');

    showEnableInOutPorts=checkShowEnableInOutPorts(block);
    for varCount=numel(aoiVarList):-1:1
        currentVar=aoiVarList(varCount);
        checkVar(currentVar);
        if strcmpi(currentVar.PortType,'hidden')
            aoiVarList(varCount)=[];
        elseif strcmpi(currentVar.PortType,'inport/outport')
            aoiVarList(varCount).Name=[currentVar.Name,'_In'];
            aoiVarList(varCount).Scope='Input';
            aoiVarList(varCount).PortType='Inport';
            aoiVarList(end+1)=currentVar;%#ok<AGROW>
            aoiVarList(end).Name=[currentVar.Name,'_Out'];
            aoiVarList(end).Scope='Output';
            aoiVarList(end).PortType='Outport';
        elseif strcmpi(currentVar.PortType,'inport')
            if~strcmpi(currentVar.Name,'EnableIn')
                aoiVarList(varCount).Name=[currentVar.Name,'_In'];
                aoiVarList(varCount).Scope='Input';
                aoiVarList(varCount).PortIndex=num2str(str2double(currentVar.PortIndex)-1);
            elseif~showEnableInOutPorts
                aoiVarList(varCount)=[];
            end
        elseif strcmpi(currentVar.PortType,'outport')
            if~strcmpi(currentVar.Name,'EnableOut')
                aoiVarList(varCount).Name=[currentVar.Name,'_Out'];
                aoiVarList(varCount).Scope='Output';
                aoiVarList(varCount).PortIndex=num2str(str2double(currentVar.PortIndex)-1);
            elseif~showEnableInOutPorts
                aoiVarList(varCount)=[];
            end
        end
    end

    aoiDataName=slplc.utils.getParam(aoiBlock,'PLCOperandTag');
    aoiName=slplc.utils.getParam(aoiBlock,'PLCPOUName');
    aoiDataType=['Bus: ',aoiName];
    aoiVar=slplc.utils.createNewVar(aoiDataName,'Local','1',aoiDataType,'',true,'ReadWrite');
    aoiVarList(end+1)=aoiVar;

    slplc.utils.setVariableList(block,aoiVarList);
    updateInterfaceBlocks(aoiRunnerLogicBlock,aoiBlock,showEnableInOutPorts);
end

function updateInterfaceBlocks(aoiRunnerLogicBlock,aoiBlock,showEnableInOutPorts)
    aoiBlockName=get_param(aoiBlock,'name');

    portConns=get_param(aoiBlock,'PortConnectivity');
    portType='Inport';
    previouPortNum=0;

    for connCount=1:numel(portConns)
        currentConn=portConns(connCount);
        portNumOrType=currentConn.Type;
        if str2double(portNumOrType)<=previouPortNum
            portType='Outport';
        end
        portsInAOIBlock=plc_find_system(aoiBlock,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType',portType,'Port',portNumOrType);
        portsInAOIBlock=portsInAOIBlock{1};
        portName=get_param(portsInAOIBlock,'Name');

        if strcmpi(portType,'Inport')
            portBlock='studio5000_plclib/Variable Read';
            if strcmp(portName,'RungIn')
                operandTagName='EnableIn';
                if~showEnableInOutPorts
                    portBlock='built-in/Constant';
                end
            else
                operandTagName=[portName,'_In'];
            end
            interfaceBlockFullName=[aoiRunnerLogicBlock,'/',operandTagName];
            if currentConn.SrcBlock<0
                safe_add_interface_block(portBlock,interfaceBlockFullName,operandTagName);
                add_line(aoiRunnerLogicBlock,[operandTagName,'/1'],[aoiBlockName,'/',portNumOrType]);
            end
            connPosition=currentConn.Position;
            portPosition=[connPosition(1)-150,connPosition(2)-7,connPosition(1)-70,connPosition(2)+7];
            set_param(interfaceBlockFullName,'Priority','');
            set_param(interfaceBlockFullName,'Position',portPosition);
        elseif strcmpi(portType,'Outport')
            portBlock='studio5000_plclib/Variable Write';
            if strcmp(portName,'RungOut')
                operandTagName='EnableOut';
                if~showEnableInOutPorts
                    portBlock='built-in/Terminator';
                end
            else
                operandTagName=[portName,'_Out'];
            end
            interfaceBlockFullName=[aoiRunnerLogicBlock,'/',operandTagName];
            if isempty(currentConn.DstBlock)||(isscalar(currentConn.DstBlock)&&currentConn.DstBlock<=0)
                safe_add_interface_block(portBlock,interfaceBlockFullName,operandTagName);
                add_line(aoiRunnerLogicBlock,[aoiBlockName,'/',portNumOrType],[operandTagName,'/1']);
            end
            connPosition=currentConn.Position;
            portPosition=[connPosition(1)+70,connPosition(2)-7,connPosition(1)+150,connPosition(2)+7];
            set_param(interfaceBlockFullName,'Priority','');
            set_param(interfaceBlockFullName,'Position',portPosition);
        end
        previouPortNum=str2double(portNumOrType);
    end

end

function blkH=safe_add_interface_block(src,dst,operandTagName,varargin)
    blkH=-1;
    if getSimulinkBlockHandle(dst)<=0

        blkH=add_block(src,dst,varargin{:});
        if strcmp(get_param(blkH,'BlockType'),'Constant')
            set_param(blkH,'Value','true');
        elseif strcmp(get_param(blkH,'BlockType'),'Terminator')
        else
            set_param(blkH,'PLCOperandTag',operandTagName);
        end
    end
end

function keep_enable=checkShowEnableInOutPorts(block)
    try
        mdl_name=bdroot(block);
        enable_param=get_param(mdl_name,plccore.common.PLCLadderMgr.PreserveAOIEnableParam);
        keep_enable=strcmpi(enable_param,'on');
    catch ME
        if(strcmp(ME.identifier,'Simulink:Commands:ParamUnknown'))
            keep_enable=false;
        else
            rethrow(ME);
        end
    end
end

function checkVar(var)
    try
        checkName(var.Name);
    catch
        import plccore.common.plcThrowError
        plcThrowError('plccoder:plccore:TBUnsupportedVar','Variable',var.Name);
    end

    try
        dType=strrep(var.DataType,'Bus: ','');
        checkName(dType);
    catch
        import plccore.common.plcThrowError
        plcThrowError('plccoder:plccore:TBUnsupportedVar','DataType',dType);
    end
end

function checkName(name)
    if~isvarname(name)||length(name)>slplc.utils.getTargetParam('targetMaxLength')
        error('Invalid name for AOI Runner')
    end
end


