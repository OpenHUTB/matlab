function savePortInterfaceToModel(obj)



    if obj.isMLHDLC
        return;
    end

    if~obj.hTurnkey.hD.getloadingFromModel

        for ii=1:length(obj.hIOPortList.InputPortNameList)
            portName=obj.hIOPortList.InputPortNameList{ii};
            hIOPort=obj.hIOPortList.getIOPort(portName);

            if~hIOPort.isTunable
                portFullName=hIOPort.PortFullName;
                interfaceStr=obj.hTableMap.getInterfaceStr(portName);
                if~strcmp(hdlget_param(portFullName,'IOInterface'),interfaceStr)
                    hdlset_param(portFullName,'IOInterface',interfaceStr);
                end
                bitRangeStr=obj.hTableMap.getBitRangeStr(portName);
                if~strcmp(hdlget_param(portFullName,'IOInterfaceMapping'),bitRangeStr)
                    hdlset_param(portFullName,'IOInterfaceMapping',bitRangeStr);
                end
            end
        end

        for ii=1:length(obj.hIOPortList.OutputPortNameList)
            portName=obj.hIOPortList.OutputPortNameList{ii};
            hIOPort=obj.hIOPortList.getIOPort(portName);

            if~hIOPort.isTestPoint

                portFullName=hIOPort.PortFullName;
                interfaceStr=obj.hTableMap.getInterfaceStr(portName);
                if~strcmp(hdlget_param(portFullName,'IOInterface'),interfaceStr)
                    hdlset_param(portFullName,'IOInterface',interfaceStr);
                end
                bitRangeStr=obj.hTableMap.getBitRangeStr(portName);
                if~strcmp(hdlget_param(portFullName,'IOInterfaceMapping'),bitRangeStr)
                    hdlset_param(portFullName,'IOInterfaceMapping',bitRangeStr);
                end
            end
        end



        dutName=obj.hTurnkey.hD.hCodeGen.getDutName;

        if~downstream.tool.isDUTTopLevel(dutName)&&~downstream.tool.isDUTModelReference(dutName)
            testPointMappingOnDUT={};
            testPointPortList=obj.hTestPointPortList;
            if~isempty(testPointPortList)
                numTestPoints=numel(testPointPortList.TestPointPorts);
                for ii=1:numTestPoints
                    testPointPort=testPointPortList.TestPointPorts{ii};
                    portName=testPointPort.PortName;
                    interfaceStr=obj.hTableMap.getInterfaceStr(portName);
                    bitRangeStr=obj.hTableMap.getBitRangeStr(portName);
                    testPointMappingOnDUT{end+1}={portName,interfaceStr,bitRangeStr};%#ok<AGROW>
                end
            end
            hdlset_param(dutName,'TestPointMapping',testPointMappingOnDUT);
        end



        dutName=obj.hTurnkey.hD.hCodeGen.getDutName;

        if~downstream.tool.isDUTTopLevel(dutName)&&~downstream.tool.isDUTModelReference(dutName)
            tunableParamMappingOnDUT={};
            tunableParamPortList=obj.hTunableParamPortList;
            for ii=1:numel(tunableParamPortList.TunableParamNameList)
                portName=tunableParamPortList.TunableParamNameList{ii};
                interfaceStr=obj.hTableMap.getInterfaceStr(portName);
                bitRangeStr=obj.hTableMap.getBitRangeStr(portName);
                tunableParamMappingOnDUT{end+1}={portName,interfaceStr,bitRangeStr};%#ok<AGROW>
            end
            hdlset_param(dutName,'TunableParameterMapping',tunableParamMappingOnDUT);
        end
    end

end