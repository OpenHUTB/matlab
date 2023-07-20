




classdef TargetInterfaceTable<handle


    properties

        hIOPortList=[];


        hTunableParamPortList=[];


        hTestPointPortList=[];


        hTableMap=[];


        hTurnkey=[];


        hPIRCreation=[];
    end

    properties(Dependent)

isMLHDLC
    end

    properties(Access=protected)

        hIOPortListRef=[];
        hTableMapRef=[];


        isEmlPortInfoValid=false;
        emlInputDataParams='';
        emlEntryPointPath='';
    end


    methods

        function obj=TargetInterfaceTable(hTurnkey)


            obj.hTurnkey=hTurnkey;

            obj.hIOPortList=hdlturnkey.data.IOPortList;
            obj.hTunableParamPortList=hdlturnkey.data.TunableParamPortList;
            obj.hTableMap=hdlturnkey.table.InterfaceTableMap(obj);
        end

    end


    methods
        function isit=get.isMLHDLC(obj)
            isit=obj.hTurnkey.hD.isMLHDLC;
        end
    end

    methods

        function[status,messages,errorMessage]=populateInterfaceTable(obj,dutName,emlInputDataParams,emlEntryPointPath)


            if nargin<4
                emlEntryPointPath='';
            end

            if nargin<3
                emlInputDataParams='';
            end



            obj.emlEntryPointPath=emlEntryPointPath;
            obj.emlInputDataParams=emlInputDataParams;

            if~obj.isMLHDLC
                if nargin<2
                    dutName='';
                end




                if~isempty(dutName)&&ischar(dutName)
                    mdlName=bdroot(dutName);
                    snn=hdlget_param(mdlName,'HDLSubsystem');
                    if~strcmpi(snn,dutName)
                        hdlset_param(mdlName,'HDLSubsystem',dutName);
                    end
                end
            end


            [status,messages,errorMessage]=obj.buildInterfaceTable;
        end

        function validateCell=validateInterfaceTable(obj)




            if obj.hTurnkey.hD.cliDisplay
                skipPirFE=true;
            else
                skipPirFE=false;
            end
            obj.buildInterfaceTable(skipPirFE);


            validateCell=obj.validateTable;










            if~isempty(obj.hPIRCreation)
                obj.hPIRCreation.checkNeedRunEntireMakehdl;
            end
















            obj.hTurnkey.registerDefaultBusAddress;
        end

        function cleanInterfaceTable(obj)

            obj.hIOPortList=hdlturnkey.data.IOPortList;
            obj.hTableMap=hdlturnkey.table.InterfaceTableMap(obj);
        end

        function cleanInterfaceTableMap(obj)


            obj.hTableMap=hdlturnkey.table.InterfaceTableMap(obj);
        end

        function updateInterfaceTable(obj)


            obj.buildInterfaceTable(true);
        end

        function cleanPIR(obj)%#ok<MANU>
            gp=pir;
            gp.destroy;
        end

        function isEmpty=isInterfaceTableEmpty(obj)
            isEmpty=obj.hIOPortList.IOPortMap.isempty;
        end

        function hInterfaceList=getInterfaceList(obj)
            hInterfaceList=obj.hTurnkey.getInterfaceList;
        end

    end

    methods(Access=protected)

        function[status,messages,errorMessage]=buildInterfaceTable(obj,skipPirFE)








            if nargin<2
                skipPirFE=false;
            end


            status=false;

            messages='';

            errorMessage='';

            report='';


            obj.backupInterfaceAssignment;

            obj.hIOPortListRef=obj.hIOPortList;
            obj.hTableMapRef=obj.hTableMap;
            hDI=obj.hTurnkey.hD;


            if obj.isMLHDLC
                if~obj.isEmlPortInfoValid
                    try
                        [emlPortInfo,report,errorMessage]=getEmlPortInfo(obj,obj.emlInputDataParams,obj.emlEntryPointPath);
                        messages=coderprivate.convertMessagesToJavaArray(report);
                    catch ex
                        errorMessage=ex.message;
                        return
                    end

                    obj.hIOPortList=hdlturnkey.data.IOPortList;
                    obj.hIOPortList.buildIOPortList('',hDI,emlPortInfo);
                    obj.isEmlPortInfoValid=true;
                end
            else

                p=obj.hTurnkey.hCHandle.PirInstance;
                if~obj.isValidPIR(p)||...
                    ~(skipPirFE&&...
                    (hDI.cliDisplay||obj.isAbleToSkipPirFrontEnd(p)))
















                    obj.hTunableParamPortList=hdlturnkey.data.TunableParamPortList;

                    obj.runPirFrontEnd;


                    if hDI.Verbosity>1
                        hdlDispWithTimeStamp(message('hdlcommon:workflow:ConstructTargetInterfaceTableBegin'),hDI.Verbosity);
                    end


                    obj.hIOPortList=hdlturnkey.data.IOPortList;

                    p=obj.hTurnkey.hCHandle.PirInstance;
                    obj.hIOPortList.buildIOPortList(p,hDI);

                    obj.hIOPortList.addTunableParamPortList(obj.hTunableParamPortList);


                    obj.hTestPointPortList=[];
                    if obj.hTurnkey.hCHandle.getParameter('EnableTestpoints')

                        if((hDI.isIPWorkflow||hDI.isXPCWorkflow)&&(~hDI.isISE))



                            try


                                obj.hTestPointPortList=hdlturnkey.data.TestPointPortList(obj.hTurnkey);

                                obj.hIOPortList.addTestPointPortList(obj.hTestPointPortList);
                            catch me

                                obj.cleanInterfaceTable;
                                rethrow(me);
                            end
                        end
                    end
                end
            end









            try
                obj.validateModel;
            catch ME
                obj.cleanInterfaceTable;
                rethrow(ME);
            end



            obj.hTableMap=hdlturnkey.table.InterfaceTableMap(obj);


            obj.cleanInterfaceAssignment;


            obj.hTableMap.initialTableMap;


            try







                obj.assignPreviousUserAssignment;






                if obj.hTurnkey.isCoProcessorMode


                    obj.hTableMap.buildInterfaceIOMap;


                    obj.assignCoProcessingModeInterface;
                end


                obj.assignDefaultBitRange;


                obj.hTableMap.buildInterfaceIOMap;

            catch ME


                obj.assignDefaultBitRange;


                obj.hTableMap.buildInterfaceIOMap;

                if obj.isMLHDLC&&strfind(ME.identifier,'hdlcommon:workflow:')
                    errorMessage=[errorMessage,ME.message];
                else

                    rethrow(ME);
                end
            end


            if hDI.Verbosity>1
                hdlDispWithTimeStamp(message('hdlcommon:workflow:ConstructTargetInterfaceTableComplete'),hDI.Verbosity);
            end


            obj.hTurnkey.refreshTableInterface;


            status=(isempty(report)||report.summary.passed)&&isempty(errorMessage);
        end

        function assignDefaultBitRange(obj)


            hInterfaceList=getInterfaceList(obj);
            interfaceIDList=hInterfaceList.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hInterfaceList.getInterface(interfaceID);
                hInterface.cleanInterfaceAssignment(obj);
            end


            for ii=1:length(obj.hIOPortList.InputPortNameList)
                portName=obj.hIOPortList.InputPortNameList{ii};
                obj.allocateUserSpecBitRange(portName);
            end
            for ii=1:length(obj.hIOPortList.OutputPortNameList)
                portName=obj.hIOPortList.OutputPortNameList{ii};
                obj.allocateUserSpecBitRange(portName);
            end


            for ii=1:length(obj.hIOPortList.InputPortNameList)
                portName=obj.hIOPortList.InputPortNameList{ii};
                obj.allocateDefaultBitRange(portName);
            end
            for ii=1:length(obj.hIOPortList.OutputPortNameList)
                portName=obj.hIOPortList.OutputPortNameList{ii};
                obj.allocateDefaultBitRange(portName);
            end


            for ii=1:length(obj.hIOPortList.InputPortNameList)
                portName=obj.hIOPortList.InputPortNameList{ii};
                obj.allocateUserSpecInterfaceOption(portName);
            end
            for ii=1:length(obj.hIOPortList.OutputPortNameList)
                portName=obj.hIOPortList.OutputPortNameList{ii};
                obj.allocateUserSpecInterfaceOption(portName);
            end
        end

        function allocateUserSpecBitRange(obj,portName)

            if obj.hTableMap.isBitRangeUserSpec(portName)
                hInterface=obj.hTableMap.getInterface(portName);
                hInterface.allocateUserSpecBitRange(portName,obj.hTableMap);
            end
        end

        function allocateUserSpecInterfaceOption(obj,portName)

            if obj.hTableMap.isInterfaceOptionUserSpec(portName)
                hInterface=obj.hTableMap.getInterface(portName);
                hInterface.allocateUserSpecInterfaceOption(portName,obj.hTableMap);
            else

                if~obj.isMLHDLC&&~obj.hTurnkey.hD.getloadingFromModel



                    hIOPort=obj.hIOPortList.getIOPort(portName);
                    if~hIOPort.isTunable&&~hIOPort.isTestPoint
                        portFullName=hIOPort.PortFullName;
                        hdlset_param(portFullName,'IOInterfaceOptions',{});
                    end
                end
            end
        end

        function allocateDefaultBitRange(obj,portName)

            if~obj.hTableMap.isBitRangeUserSpec(portName)
                hInterface=obj.hTableMap.getInterface(portName);
                hInterface.allocateDefaultBitRange(portName,obj.hTableMap);

                if~obj.isMLHDLC&&~obj.hTurnkey.hD.getloadingFromModel
                    bitRangeStr=hInterface.getTableCellBitRangeStr(portName,obj.hTableMap);
                    hIOPort=obj.hIOPortList.getIOPort(portName);
                    if~hIOPort.isTunable&&~hIOPort.isTestPoint



                        portFullName=hIOPort.PortFullName;
                        if~strcmp(hdlget_param(portFullName,'IOInterfaceMapping'),bitRangeStr)
                            hdlset_param(portFullName,'IOInterfaceMapping',bitRangeStr);
                        end
                    end
                end
            end
        end

        function isskip=isAbleToSkipPirFrontEnd(obj,p)




            if obj.isMLHDLC
                isskip=true;
                return;
            end


            dutName=obj.hTurnkey.hD.hCodeGen.getDutName;





            hTopNet=p.getTopNetwork;
            topName=hTopNet.Name;
            if~strcmpi(dutName,topName)
                isskip=false;
                return;
            end


            numClock=hTopNet.NumberOfPirInputPorts('clock');
            if numClock>0
                isskip=false;
                return;
            end

            isskip=true;
        end

        function isvalid=isValidPIR(~,p)
            isvalid=false;
            try
                t=p.getTopNetwork;%#ok<NASGU>
                isvalid=true;
            catch ME %#ok<NASGU>
                return;
            end
        end

        function validateInInterfaceChoice(obj,portName,interfaceStr)

            interfaceStrList=obj.getTableCellInterfaceChoice(portName);
            detectMatch=strcmpi(interfaceStrList,interfaceStr);
            if~any(detectMatch)
                error(message('hdlcommon:workflow:InterfaceMismatch',interfaceStr,...
                portName,sprintf('%s; ',interfaceStrList{:})));
            end
        end

    end

    methods(Access=protected)


        runPirFrontEnd(obj)


        validateModel(obj)
        validatePort(obj,hIOPort)
        validateCell=validateTable(obj)



        assignPreviousUserAssignment(obj)
        assignPreviousUserAssignmentOnPort(obj,portName)


        assignCoProcessingModeInterface(obj)
        assignCoProcessingModeInterfaceOnPort(obj,portName,hDefaultBusInterface)


        hNewInterface=assignInterfaceInternal(obj,portName,newInterfaceStr)


        function backupInterfaceAssignment(obj)

            for ii=1:length(obj.hIOPortList.InputPortNameList)
                portName=obj.hIOPortList.InputPortNameList{ii};
                if obj.hTableMap.isInterfaceMapKey(portName)
                    interfaceStr=obj.hTableMap.getInterfaceStr(portName);
                    obj.hTableMap.backupInterfaceStr(portName,interfaceStr);
                    bitRangeStr=obj.hTableMap.getBitRangeStr(portName);
                    obj.hTableMap.backupBitRangeStr(portName,bitRangeStr);
                    interfaceOption=obj.hTableMap.getInterfaceOption(portName);
                    obj.hTableMap.backupInterfaceOption(portName,interfaceOption);
                end
            end
            for ii=1:length(obj.hIOPortList.OutputPortNameList)
                portName=obj.hIOPortList.OutputPortNameList{ii};
                if obj.hTableMap.isInterfaceMapKey(portName)
                    interfaceStr=obj.hTableMap.getInterfaceStr(portName);
                    obj.hTableMap.backupInterfaceStr(portName,interfaceStr);
                    bitRangeStr=obj.hTableMap.getBitRangeStr(portName);
                    obj.hTableMap.backupBitRangeStr(portName,bitRangeStr);
                    interfaceOption=obj.hTableMap.getInterfaceOption(portName);
                    obj.hTableMap.backupInterfaceOption(portName,interfaceOption);
                end
            end
        end

        function cleanInterfaceAssignment(obj)

            hInterfaceList=getInterfaceList(obj);
            interfaceIDList=hInterfaceList.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hInterfaceList.getInterface(interfaceID);
                hInterface.cleanInterfaceChannelAssignment;
                hInterface.cleanInterfaceAssignment(obj);
            end
        end

    end


    methods(Access=public)


        [launchAddInterfaceGUI,launchSetInterfaceOptGUI]=setInterfaceTableGUI(obj,rowIdx,colIdx,newValue)


        msg=loadPortInterfacefromModel(obj);


        setInterfaceStr(obj,portName,interfaceStr);


        tablesetting=drawGUITable(obj)


        parseGUITable(obj,tablesetting)


        interfaceChoiceStr=getTableCellInterfaceChoice(obj,portName)

    end

    methods(Access=protected)


        tdata=drawGUITableRow(obj,tdata,rowIdx,portName)


        parseGUITableRow(obj,tdata,rowIdx)


        setTableCellInterface(obj,portName,newInterfaceStr)
        setTableCellBitRange(obj,portName,newBitRangeStr)
        setInterfaceOptionalParams(obj,portName,optParamPVPair)

    end


    methods(Access=public)


        drawCmdTable(obj,populateTable)
        drawCmdTableSet(obj)


        setInterfaceStrCmd(obj,portName,interfaceStr)
        function setBitRangeStrCmd(obj,portName,bitRangeStr)
            obj.setTableCellBitRange(portName,bitRangeStr);
        end
        function interfaceStr=getInterfaceStr(obj,portName)
            interfaceStr=obj.hTableMap.getInterfaceStr(portName);
        end
        function bitRangeStr=getBitRangeStr(obj,portName)
            bitRangeStr=obj.hTableMap.getBitRangeStr(portName);
        end


        [table,header]=drawReportTable(obj)


        [status,messages,errorMessage]=buildInterfaceTableMLHDLC(obj,inputDataParams,designFcnFilepath)

    end

    methods(Access=protected)


        [tableSpan,setSpan]=drawCmdTableTitle(obj)
        drawCmdTableRow(obj,portName,tableSpan)
        drawCmdTableRowSet(obj,portName,setSpan)


        table=drawReportTableRow(obj,portName,table)


        table=drawReportTableRowBus(obj,table,...
        interfaceStr,interfaceOptStr,...
        hAddrList,hIOPort,portName,indentStr)


        [portInfo,inferenceReport,errorMessage]=getEmlPortInfo(obj,inputDataParams,designFcnFilepath)

    end

    methods(Static)

        assignedInterfaces=getAssignedInterfacesFromUITable(hInterfaceList)

    end
end


