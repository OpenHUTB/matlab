function msg=loadPortInterfacefromModel(obj)



    if obj.isMLHDLC
        return;
    end

    obj.hTurnkey.hD.setloadingFromModel(true);
    msg={};


    for ii=1:length(obj.hIOPortList.InputPortNameList)
        portName=obj.hIOPortList.InputPortNameList{ii};
        hIOPort=obj.hIOPortList.getIOPort(portName);

        if~hIOPort.isTunable
            portFullName=hIOPort.PortFullName;
            interfaceStr=hdlget_param(portFullName,'IOInterface');
            if~isempty(interfaceStr)
                successInterfaceSetting=false;
                try
                    obj.setInterfaceStr(portName,interfaceStr);
                    successInterfaceSetting=true;
                catch me
                    msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceSettingFromModel',portFullName,interfaceStr,me.message));
                    msg{end+1}=msg1;%#ok<AGROW>
                    obj.hTurnkey.hD.labelerrorModelSetting;
                end
                if successInterfaceSetting

                    optParams=hdlget_param(portFullName,'IOInterfaceOptions');
                    if~isempty(optParams)
                        try
                            obj.setTableCellOption(portName,optParams);
                        catch me
                            msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceOptionsSettingFromModel',portFullName,strjoin(optParams),me.message));
                            msg{end+1}=msg1;%#ok<AGROW>
                            obj.hTurnkey.hD.labelerrorModelSetting;
                        end
                    end

                    bitRangeStr=hdlget_param(portFullName,'IOInterfaceMapping');
                    if~isempty(bitRangeStr)
                        try






                            hInterface=obj.hTableMap.getInterface(portName);
                            if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface&&strcmp(bitRangeStr,'Auto')
                                bitRangeStr='Data';
                            end
                            obj.setTableCellBitRange(portName,bitRangeStr);
                        catch me
                            msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceMappingSettingFromModel',portFullName,bitRangeStr,me.message));
                            msg{end+1}=msg1;%#ok<AGROW>
                            obj.hTurnkey.hD.labelerrorModelSetting;
                        end
                    end
                end
            end
        end
    end


    for ii=1:length(obj.hIOPortList.OutputPortNameList)
        portName=obj.hIOPortList.OutputPortNameList{ii};
        hIOPort=obj.hIOPortList.getIOPort(portName);
        if~hIOPort.isTestPoint

            portFullName=hIOPort.PortFullName;
            interfaceStr=hdlget_param(portFullName,'IOInterface');


            if(strcmp(interfaceStr,'FPGA Data Capture - JTAG'))
                interfaceStr='FPGA Data Capture';
            end

            if~isempty(interfaceStr)
                successInterfaceSetting=false;
                try
                    obj.setInterfaceStr(portName,interfaceStr);
                    successInterfaceSetting=true;
                catch me
                    msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceSettingFromModel',portFullName,interfaceStr,me.message));
                    msg{end+1}=msg1;%#ok<AGROW>
                    obj.hTurnkey.hD.labelerrorModelSetting;
                end
                if successInterfaceSetting

                    bitRangeStr=hdlget_param(portFullName,'IOInterfaceMapping');
                    if~isempty(bitRangeStr)
                        try






                            hInterface=obj.hTableMap.getInterface(portName);
                            if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface&&strcmp(bitRangeStr,'Auto')
                                bitRangeStr='Data';
                            end
                            obj.setTableCellBitRange(portName,bitRangeStr);
                        catch me
                            msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceMappingSettingFromModel',portFullName,bitRangeStr,me.message));
                            msg{end+1}=msg1;%#ok<AGROW>
                            obj.hTurnkey.hD.labelerrorModelSetting;
                        end
                    end

                    optParams=hdlget_param(portFullName,'IOInterfaceOptions');
                    if~isempty(optParams)
                        try
                            obj.setTableCellOption(portName,optParams);
                        catch me
                            msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceOptionsSettingFromModel',portFullName,strjoin(optParams),me.message));
                            msg{end+1}=msg1;%#ok<AGROW>
                            obj.hTurnkey.hD.labelerrorModelSetting;
                        end
                    end
                end
            end
        end
    end



    dutName=obj.hTurnkey.hD.hCodeGen.getDutName;

    if~downstream.tool.isDUTTopLevel(dutName)&&~downstream.tool.isDUTModelReference(dutName)

        tunableParamMappingOnDUT=hdlget_param(dutName,'TunableParameterMapping');
        if~isempty(tunableParamMappingOnDUT)

            if obj.validateTunableParamMappingOnDUT(tunableParamMappingOnDUT)

                tunableParamPortList=obj.hTunableParamPortList;

                for ii=1:numel(tunableParamPortList.TunableParamNameList)

                    portName=tunableParamPortList.TunableParamNameList{ii};


                    findTunableParamPort=tunableParamMappingOnDUT(cellfun(@(var)strcmp(var{1},portName),tunableParamMappingOnDUT));
                    if~isempty(findTunableParamPort)
                        if length(findTunableParamPort)==1

                            findTunableParamPort=findTunableParamPort{1};

                            hTunablePort=tunableParamPortList.TunableParamPortMap(findTunableParamPort{1});
                            portFullName=hTunablePort.PortFullName;

                            interfaceStr=findTunableParamPort{2};


                            if(strcmp(interfaceStr,'FPGA Data Capture - JTAG'))
                                interfaceStr='FPGA Data Capture';
                            end

                            if~isempty(interfaceStr)
                                successInterfaceSetting=false;
                                try
                                    obj.setInterfaceStr(portName,interfaceStr);
                                    successInterfaceSetting=true;
                                catch me
                                    msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceSettingFromModel',portFullName,interfaceStr,me.message));
                                    msg{end+1}=msg1;%#ok<AGROW>
                                    obj.hTurnkey.hD.labelerrorModelSetting;
                                end
                                if successInterfaceSetting

                                    bitRangeStr=findTunableParamPort{3};
                                    if~isempty(bitRangeStr)
                                        try
                                            obj.setTableCellBitRange(portName,bitRangeStr);
                                        catch me
                                            msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceMappingSettingFromModel',portFullName,bitRangeStr,me.message));
                                            msg{end+1}=msg1;%#ok<AGROW>
                                            obj.hTurnkey.hD.labelerrorModelSetting;
                                        end
                                    end
                                end
                            end
                        else

                            msg1=MException(message('hdlcommon:workflow:DuplicateTunableParameters',dutName,portName));
                            msg{end+1}=msg1;%#ok<AGROW>
                            obj.hTurnkey.hD.labelerrorModelSetting;
                        end
                    end
                end
            else

                msg1=MException(message('hdlcommon:workflow:ApplyTunableParameterMappingSettingFromDUT',dutName,hdlCellArray2Str({{'a','AXI4-Lite','x"114"'},{'b','External Port',''}})));
                msg{end+1}=msg1;
                obj.hTurnkey.hD.labelerrorModelSetting;
            end
        end
    end



    dutName=obj.hTurnkey.hD.hCodeGen.getDutName;

    if~downstream.tool.isDUTTopLevel(dutName)&&~downstream.tool.isDUTModelReference(dutName)

        testPointMappingOnDUT=hdlget_param(dutName,'TestPointMapping');
        if~isempty(testPointMappingOnDUT)

            testPointPortList=obj.hTestPointPortList;
            if~isempty(testPointPortList)
                numTestPointPorts=numel(testPointPortList.TestPointPorts);

                for ii=1:numTestPointPorts

                    portName=testPointPortList.TestPointPorts{ii}.PortName;
                    portFullName=testPointPortList.TestPointPorts{ii}.PortFullName;


                    findTestPointPort=testPointMappingOnDUT(cellfun(@(var)strcmp(var{1},portName),testPointMappingOnDUT));
                    if~isempty(findTestPointPort)
                        if length(findTestPointPort)==1

                            findTestPointPort=findTestPointPort{1};

                            interfaceStr=findTestPointPort{2};


                            if(strcmp(interfaceStr,'FPGA Data Capture - JTAG'))
                                interfaceStr='FPGA Data Capture';
                            end

                            if~isempty(interfaceStr)
                                successInterfaceSetting=false;
                                try
                                    obj.setInterfaceStr(portName,interfaceStr);
                                    successInterfaceSetting=true;
                                catch me
                                    msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceSettingFromModel',portFullName,interfaceStr,me.message));
                                    msg{end+1}=msg1;%#ok<AGROW>
                                    obj.hTurnkey.hD.labelerrorModelSetting;
                                end
                                if successInterfaceSetting

                                    bitRangeStr=findTestPointPort{3};
                                    if~isempty(bitRangeStr)
                                        try
                                            obj.setTableCellBitRange(portName,bitRangeStr);
                                        catch me
                                            msg1=MException(message('hdlcommon:workflow:ApplyIOInterfaceMappingSettingFromModel',portFullName,bitRangeStr,me.message));
                                            msg{end+1}=msg1;%#ok<AGROW>
                                            obj.hTurnkey.hD.labelerrorModelSetting;
                                        end
                                    end
                                end
                            end
                        else

                            msg1=MException(message('hdlcommon:workflow:DuplicateTestPoints',dutName,portName));
                            msg{end+1}=msg1;%#ok<AGROW>
                            obj.hTurnkey.hD.labelerrorModelSetting;
                        end
                    end
                end
            end
        end
    end

    obj.hTurnkey.hD.setloadingFromModel(false);

end