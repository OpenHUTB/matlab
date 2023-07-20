


classdef(Abstract)SoftwareInterfaceBase<matlab.mixin.SetGetExactNames


    properties(SetAccess=protected)



        InterfaceID='';

    end

    properties(Abstract,Access=protected)
AddInterfaceMethod
    end

    properties(Access=protected)
        MapPortMethod='mapPort';
        WritePortMethod='writePort';
        ReadPortMethod='readPort';
    end

    properties(Access=protected)

        hIOPortList=[];
    end

    methods
        function obj=SoftwareInterfaceBase(interfaceID)


            obj.InterfaceID=interfaceID;
            obj.hIOPortList=hdlturnkey.data.IOPortListBase;
        end

        function populateAssignedPorts(obj,hTurnkey)
            obj.hIOPortList.clearIOPortList();

            portNameList=hTurnkey.hTable.hTableMap.getConnectedPortList(obj.InterfaceID);
            for ii=1:length(portNameList)
                portName=portNameList{ii};
                hIOPort=hTurnkey.hTable.hIOPortList.getIOPort(portName);
                obj.hIOPortList.addIOPort(hIOPort);
            end
        end

        function isa=isEmptyInterface(~)
            isa=false;
        end
    end


    methods

        function validateInterface(obj)

        end
    end


    methods
        function registerDeviceTreeNames(obj,hNameService,ipDeviceName)%#ok<INUSD>

        end
    end

    methods(Abstract)

        validateCell=generateDeviceTreeNodes(obj,hIPCoreNode)













        validateCell=generateModelDriver(obj,hModelGen)


        validateCell=generateScriptDriver(obj,hScriptGen)



        validateCell=generateInterfaceAccessCommand(obj,hScriptGen)
    end


    methods(Access=protected)
        function stubAllPorts(obj,hModelGen,removePorts)
            if nargin<3
                removePorts=hModelGen.isUnusedPortRemoved;
            end

            inPortList=obj.hIOPortList.InputPortNameList;
            outPortList=obj.hIOPortList.OutputPortNameList;
            obj.stubPorts(hModelGen,[inPortList,outPortList],removePorts);
        end

        function stubPorts(obj,hModelGen,portList,removePorts)

            if nargin<4
                removePorts=hModelGen.isUnusedPortRemoved;
            end


            portList=downstream.tool.convertToCell(portList);

            for ii=1:length(portList)
                portName=portList{ii};
                hIOPort=obj.hIOPortList.getIOPort(portName);
                portPath=hModelGen.getTIFDutPort(portName);


                if removePorts
                    hModelGen.removeBlock(portPath);
                    continue;
                end


                switch hIOPort.PortType
                case hdlturnkey.IOType.IN
                    hModelGen.addTerminatorBlock('Right',portPath);
                case hdlturnkey.IOType.OUT
                    if hIOPort.isBus



                        obj.addBusCreatorSubsystem(hModelGen,portPath,hIOPort.Type);
                    else






                        outputDataType=fixdt(hIOPort.SLDataType);
                        dtcBlockPath=hModelGen.addDTCBlock('Left',portPath,outputDataType);
                        hModelGen.addGroundBlock('Left',dtcBlockPath);
                    end
                end
            end
        end
    end

    methods(Static,Access=protected)
        function subsysPath=addBusCreatorSubsystem(hModelGen,destBlockPath,busType)


            busMemberNumber=busType.getNumMembers;
            busMemberIDList=busType.getMemberIDList;
            busMemberSLDataType=busType.getMemberSLDataTypeList;

            subsysBlockList={};


            busBlock='simulink/Signal Routing/Bus Creator';
            busBlockParams={'Inputs',num2str(busMemberNumber)};
            busBlockPath=hModelGen.addLibraryBlock(busBlock,'Left',destBlockPath,busBlockParams);
            subsysBlockList{end+1}=busBlockPath;

            for ii=1:busMemberNumber
                dataType=fixdt(busMemberSLDataType{ii});
                [constBlockPath,hLine]=hModelGen.addConstantBlock('Left',busBlockPath,0,dataType,'DestBlockPort',ii);
                subsysBlockList{end+1}=constBlockPath;%#ok<AGROW>
                set_param(hLine,'Name',busMemberIDList{ii});
            end


            subsysName=sprintf('BusGround_%s',hModelGen.getNewBlockName(destBlockPath));
            subsysPath=hModelGen.createSubsystem(subsysBlockList,subsysName,true);
        end
    end


    methods(Access=protected)

        function generateAddInterfaceCommand(obj,hScriptGen,pvPairs)







            fileID=hScriptGen.FileID;

            pvPairsStr=hScriptGen.getPVPairsSyntax(pvPairs,true);
            hScriptGen.addFunctionCall(fileID,obj.AddInterfaceMethod,{hScriptGen.HardwareObjectVarName,pvPairsStr},{});
        end

        function generateDUTPortConstructor(obj,hScriptGen,portList)






            if nargin<3

                inPortList=obj.hIOPortList.InputPortNameList;
                outPortList=obj.hIOPortList.OutputPortNameList;
                portList=[inPortList,outPortList];
            end


            portList=downstream.tool.convertToCell(portList);


            fileID=hScriptGen.FileID;

            for ii=1:length(portList)
                portName=portList{ii};
                hIOPort=obj.hIOPortList.getIOPort(portName);
                hDUTPort=obj.createDUTPort(hIOPort);
                hDUTPort.serialize(hScriptGen);
                hScriptGen.addEmptyLine(fileID);
            end
        end

        function hDUTPorts=createDUTPort(obj,hIOPort)%#ok<INUSL>







            hDUTPorts=fpgaio.data.DUTPort.constructFromIOPort(hIOPort);
        end

        function generateMapPortCommand(obj,hScriptGen,portList)






            if nargin<3

                inPortList=obj.hIOPortList.InputPortNameList;
                outPortList=obj.hIOPortList.OutputPortNameList;
                portList=[inPortList,outPortList];
            end


            portList=downstream.tool.convertToCell(portList);


            fileID=hScriptGen.FileID;


            portVarList={};
            for ii=1:length(portList)
                portName=portList{ii};
                hIOPort=obj.hIOPortList.getIOPort(portName);
                hDUTPort=obj.createDUTPort(hIOPort);
                portVarList{end+1}=hDUTPort.getPortVarName;%#ok<AGROW>
            end


            if~isempty(portList)
                portVarListStr=['[',strjoin(portVarList,', '),']'];
                hScriptGen.addFunctionCall(fileID,obj.MapPortMethod,{hScriptGen.HardwareObjectVarName,portVarListStr},{});
            end
        end

        function generatePortAccessCommand(obj,hScriptGen,portList,dataList)



















            if nargin<3

                inPortList=obj.hIOPortList.InputPortNameList;
                outPortList=obj.hIOPortList.OutputPortNameList;
                portList=[inPortList,outPortList];
            end

            if nargin<4
                dataList=cell(size(portList));
            end


            portList=downstream.tool.convertToCell(portList);
            dataList=downstream.tool.convertToCell(dataList);

            assert(length(portList)==length(dataList),'Data list must be same length as port list.');


            for ii=1:length(portList)
                portName=portList{ii};
                hIOPort=obj.hIOPortList.getIOPort(portName);
                hDUTPort=obj.createDUTPort(hIOPort);


                dataStr=dataList{ii};
                if isempty(dataStr)
                    dataStr=obj.getSampleDataStr(portName);
                end


                fileID=hScriptGen.FileID;




                if hDUTPort.isBusPort
                    hScriptGen.addEmptyLine(fileID);
                    if hDUTPort.isInputPort
                        hScriptGen.addComment(fileID,'There are two ways to write a DUT bus ports');
                        hScriptGen.addComment(fileID,'(1). Prepare a struct value and write it to the whole bus port.');
                    else
                        hScriptGen.addComment(fileID,'There are two ways to read a DUT bus ports');
                        hScriptGen.addComment(fileID,'(1). Read the whole bus port, and it will returns a struct value.');
                    end
                end


                portNameStr=sprintf('"%s"',hDUTPort.Name);
                obj.generateReadWritePortCommand(hScriptGen,hDUTPort,portNameStr,dataStr);



                if hDUTPort.isBusPort
                    if hDUTPort.isInputPort
                        hScriptGen.addComment(fileID,'(2). Prepare a value for each member of the bus and write it individually.');
                    else
                        hScriptGen.addComment(fileID,'(2). Read each member of the bus individually.');
                    end
                    [subPortsList,flattenedPortNameList]=hDUTPort.getAllSubPorts;
                    for jj=1:length(subPortsList)

                        subPort=subPortsList(jj);
                        flattenedPortName=flattenedPortNameList(jj);
                        dataStr=subPort.getSampleDataStr(flattenedPortName);
                        flattenedPortNameStr=sprintf('"%s"',flattenedPortName);
                        obj.generateReadWritePortCommand(hScriptGen,subPort,flattenedPortNameStr,dataStr);
                    end
                    hScriptGen.addEmptyLine(fileID);
                end
            end
        end

        function generateReadWritePortCommand(obj,hScriptGen,hDUTPort,portNameStr,dataStr)



            fileID=hScriptGen.FileID;
            if hDUTPort.isInputPort
                hScriptGen.addFunctionCall(fileID,obj.WritePortMethod,{hScriptGen.HardwareObjectVarName,portNameStr,dataStr},{},'GenerateAsComment',true);
            else
                hScriptGen.addFunctionCall(fileID,obj.ReadPortMethod,{hScriptGen.HardwareObjectVarName,portNameStr},{dataStr},'GenerateAsComment',true);
            end
        end

        function dataStr=getSampleDataStr(obj,portName)
            hIOPort=obj.hIOPortList.getIOPort(portName);
            hDUTPort=obj.createDUTPort(hIOPort);
            dataStr=hDUTPort.getSampleDataStr;
        end

    end

end
