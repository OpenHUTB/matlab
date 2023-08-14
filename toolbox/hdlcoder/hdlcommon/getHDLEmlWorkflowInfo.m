function[list,defEntry]=getHDLEmlWorkflowInfo(key,portName)



    list='';
    defEntry='';
    if nargin<2
        portName='';
    end

    persistent targetTable

    if isempty(targetTable)
        hdlDrv=hdlcurrentdriver;
        if isempty(hdlDrv)
            return
        end
        assert(isprop(hdlDrv,'DownstreamIntegrationDriver')&&isprop(hdlDrv.DownstreamIntegrationDriver,'hTurnkey'));
        if isempty(hdlDrv)||isempty(hdlDrv.DownstreamIntegrationDriver)||isempty(hdlDrv.DownstreamIntegrationDriver.hTurnkey)
            targetTable='';
        else
            targetTable=hdlDrv.DownstreamIntegrationDriver.hTurnkey.hTable;
        end
    end

    if~isempty(targetTable)
        if~isempty(portName)
            try
                hIOPort=targetTable.hIOPortList.getIOPort(portName);
            catch me %#ok<*NASGU>
                list='';
                defEntry='';
                return
            end

            if strcmpi(key,'PortType')
                list=hIOPort.getPortTypeStr;
                defEntry=list;
            elseif strcmpi(key,'DispDataType')
                list=hIOPort.DispDataType;
                defEntry=list;
            elseif strcmpi(key,'Interface')
                list=targetTable.getTableCellInterfaceChoice(portName);
                defEntry=targetTable.hTableMap.getInterfaceIdx(portName);
            elseif strcmpi(key,'BitRange')
                list=targetTable.hTableMap.getBitRangeStr(portName);
                defEntry=list;
            end
            return
        end

        if strcmpi(key,'TargetFrequency')
            try
                list=targetTable.hTurnkey.hD.getTargetFrequency;
            catch me %#ok<*NASGU>
                list='';
            end
            defEntry=list;
        elseif strcmpi(key,'IPCoreName')
            try
                list=targetTable.hTurnkey.hD.hIP.getIPCoreName;
            catch me %#ok<*NASGU>
                list='';
            end
            defEntry=list;
        elseif strcmpi(key,'IPCoreVersion')
            try
                list=targetTable.hTurnkey.hD.hIP.getIPCoreVersion;
            catch me %#ok<*NASGU>
                list='';
            end
            defEntry=list;
        elseif strcmpi(key,'reset')
            targetTable='';
        end

    end