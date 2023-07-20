function validateCell=runCallbackPostTargetInterface(hDI)




    validateCell={};

    hRD=hDI.hIP.getReferenceDesignPlugin;
    if isempty(hRD)||isempty(hRD.PostTargetInterfaceFcn)
        return;
    end




















    infoStruct.ReferenceDesignObject=hRD;
    infoStruct.BoardObject=hDI.hTurnkey.hBoard;
    infoStruct.ParameterStruct=hRD.getParameterStructFormat;
    infoStruct.HDLModelDutPath=hDI.getDutName;
    infoStruct.ProcessorFPGASynchronization=hDI.get('ExecutionMode');


    infoStruct.InterfaceStructCell={};
    inPortList=hDI.hTurnkey.hTable.hIOPortList.InputPortNameList;
    for ii=1:length(inPortList)
        portName=inPortList{ii};
        portInfo=getPortInfo(hDI,portName);
        infoStruct.InterfaceStructCell{end+1}=portInfo;
    end
    outPortList=hDI.hTurnkey.hTable.hIOPortList.OutputPortNameList;
    for ii=1:length(outPortList)
        portName=outPortList{ii};
        portInfo=getPortInfo(hDI,portName);
        infoStruct.InterfaceStructCell{end+1}=portInfo;
    end


    fcnNumOut=nargout(hRD.PostTargetInterfaceFcn);
    if fcnNumOut==1
        validateCell=feval(hRD.PostTargetInterfaceFcn,infoStruct);
    else
        feval(hRD.PostTargetInterfaceFcn,infoStruct);
    end

end


function portInfo=getPortInfo(hDI,portName)

    hIOPort=hDI.hTurnkey.hTable.hIOPortList.getIOPort(portName);
    portInfo.PortName=portName;
    portInfo.PortType=downstream.tool.getPortDirTypeStr(hIOPort.PortType);
    portInfo.DataType=hIOPort.DispDataType;


    interfaceStr=hDI.getTargetInterface(portName);
    bitRangeStr=hDI.getTargetOffset(portName);
    portInfo.IOInterface=interfaceStr;
    portInfo.IOInterfaceMapping=bitRangeStr;

end

