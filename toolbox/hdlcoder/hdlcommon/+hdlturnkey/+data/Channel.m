


classdef(Abstract)Channel<handle





    properties(Access=public)

        ChannelID='';
        ChannelDirType=hdlturnkey.IOType.INOUT;

    end

    properties(Access=protected)


        SubPortIDList={};


        SubPortMap=[];


        InputSubPortIDList={};
        OutputSubPortIDList={};


        ModelPortSubPortMap=[];


        hEmptyPort=[];



        ExclusiveSubPortMap=containers.Map();


        CodeGenPortNameList={};

    end

    properties(Constant,Access=protected)

        EmptyPortID='Not Specified';
        OptionalPostFixRegExp=' \(optional\)$';

    end

    methods(Access=public)

        function obj=Channel(channelID)

            obj.ChannelID=channelID;

            obj.SubPortIDList={};
            obj.SubPortMap=containers.Map();
            obj.InputSubPortIDList={};
            obj.OutputSubPortIDList={};
            obj.ModelPortSubPortMap=containers.Map();
            obj.ExclusiveSubPortMap=containers.Map();
            obj.CodeGenPortNameList={};


            obj.hEmptyPort=obj.addEmptyPort(obj.EmptyPortID);

        end


        function hPort=addPort(obj,subPortID,portName,...
            hDataType,isRequiredPort,portType,portRegExp,portDirType)

            hPort=hdlturnkey.data.SubPort(subPortID);
            hPort.initilizePort(portName,...
            hDataType,isRequiredPort,portType,portRegExp,portDirType);
            obj.addPortShared(subPortID,hPort);
        end

        function list=getPortIDList(obj)

            list=obj.SubPortIDList;
        end
        function list=getInputPortIDList(obj)
            list=obj.InputSubPortIDList;
        end
        function list=getOutputPortIDList(obj)
            list=obj.OutputSubPortIDList;
        end
        function list=getPortIDListDir(obj,portDirType)
            switch(portDirType)
            case hdlturnkey.IOType.IN
                list=obj.getInputPortIDList;
            case hdlturnkey.IOType.OUT
                list=obj.getOutputPortIDList;
            otherwise
                list={};
            end
        end
        function hPort=getPort(obj,subPortIDStr)
            subPortID=filterOptionalPostFix(obj,subPortIDStr);
            hPort=obj.SubPortMap(subPortID);
        end
        function isa=isExistingPort(obj,subPortIDStr)
            subPortID=filterOptionalPostFix(obj,subPortIDStr);
            isa=obj.SubPortMap.isKey(subPortID);
        end


        function hEmptyPort=getEmptyPort(obj)
            hEmptyPort=obj.hEmptyPort;
        end
        function portID=getEmptyPortID(obj)
            portID=obj.EmptyPortID;
        end
        function isa=isEmptyPortID(obj,subPortID)
            isa=strcmpi(subPortID,obj.EmptyPortID);
        end
        function isa=isEmptyPort(obj,hPort)
            isa=obj.hEmptyPort==hPort;
        end


        function cleanPortAssignment(obj)

            subPortIDList=obj.getPortIDList;
            for ii=1:length(subPortIDList)
                subPortID=subPortIDList{ii};
                hPort=obj.getPort(subPortID);
                hPort.cleanPortAssignment;
            end
            obj.ModelPortSubPortMap=containers.Map();
        end

        function assignSubPort(obj,portName,subPortID,hTableMap)



            if obj.ModelPortSubPortMap.isKey(portName)
                oldSubPortID=obj.ModelPortSubPortMap(portName);
                hPort=obj.getPort(oldSubPortID);
                hPort.removePortAssignment(portName);
            end


            hPort=obj.getPort(subPortID);
            hPort.setPortAssignment(portName,hTableMap);
            obj.ModelPortSubPortMap(portName)=subPortID;
        end

        function subPortIDStrOut=allocateSubPortRegExp(obj,hIOPort)


            modelPortDir=hIOPort.PortType;
            subPortIDList=obj.getPortIDListDir(modelPortDir);

            selectedSubPort='';
            for ii=1:numel(subPortIDList)
                subPortIDStr=subPortIDList{ii};
                hSubPort=obj.getPort(subPortIDStr);
                if~hSubPort.isAssigned&&~isempty(hSubPort.PortRegExp)



                    if(hSubPort.hDataType.getMaxWordLength>=hIOPort.WordLength)&&...
                        ~isempty(regexpi(hIOPort.PortName,hSubPort.PortRegExp))
                        selectedSubPort=subPortIDStr;
                        break;
                    end
                end
            end

            if isempty(selectedSubPort)
                subPortIDStrOut=obj.getEmptyPortID;
            else
                subPortIDStrOut=selectedSubPort;
            end
        end


        function[isa,hPort]=isAnySubPortAssigned(obj)

            isa=false;
            hPort=[];
            subPortIDList=obj.getPortIDList;
            for ii=1:length(subPortIDList)
                subPortID=subPortIDList{ii};
                hPort=obj.getPort(subPortID);
                if hPort.isAssigned
                    isa=true;
                    return;
                end
            end
        end
        function[isa,hPort]=isNonEmptyPortAssigned(obj)

            isa=false;
            hPort=[];
            subPortIDList=obj.getPortIDList;
            for ii=1:length(subPortIDList)
                subPortID=subPortIDList{ii};
                hPort=obj.getPort(subPortID);
                if hPort.isAssigned&&~obj.isEmptyPort(hPort)
                    isa=true;
                    return;
                end
            end
        end

        function isa=isFrameModePort(~,~)
            isa=false;
        end


        function addExclusiveSubPort(obj,subPortID,subPortIDList)



            obj.ExclusiveSubPortMap(subPortID)=subPortIDList;
        end

        function list=getExclusiveSubPortIDList(obj,subPortID)
            list=obj.ExclusiveSubPortMap(subPortID);
        end

        function[isAssigned,exclusiveSubPortID]=isExclusiveSubPortAssigned(obj,subPortIDStr)


            isAssigned=false;
            exclusiveSubPortID='';
            subPortID=obj.filterOptionalPostFix(subPortIDStr);
            if obj.ExclusiveSubPortMap.length==0||~obj.ExclusiveSubPortMap.isKey(subPortID)
                return;
            end
            exclusiveSubPortIDList=obj.getExclusiveSubPortIDList(subPortID);
            for ii=1:length(exclusiveSubPortIDList)
                excSubPortID=exclusiveSubPortIDList{ii};
                hSubPort=obj.getPort(excSubPortID);
                if hSubPort.isAssigned
                    isAssigned=true;
                    exclusiveSubPortID=excSubPortID;
                    break;
                end
            end
        end


        function validateSubPort(obj,portName,bitRangeStr,hTableMap)


            subPortID=bitRangeStr;


            if obj.isEmptyPortID(subPortID)
                return;
            end

            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            modelPortDir=hIOPort.PortType;


            if~obj.isExistingPort(subPortID)
                subPortIDList=obj.getPortIDListDir(modelPortDir);
                error(message('hdlcommon:interface:SubPortInvalid',subPortID,...
                obj.ChannelID,sprintf('%s; ',subPortIDList{:})));
            end

            hSubPort=obj.getPort(subPortID);
            subPortDir=hSubPort.PortDirType;


            if subPortDir~=hdlturnkey.IOType.INOUT&&subPortDir~=modelPortDir
                error(message('hdlcommon:interface:PortTypeNotMatchSubport',...
                obj.ChannelID,subPortID,...
                downstream.tool.getPortDirTypeStr(subPortDir),...
                downstream.tool.getPortDirTypeStr(modelPortDir),hIOPort.PortName));
            end


            [isAssigned,exclusiveSubPortID]=obj.isExclusiveSubPortAssigned(subPortID);
            if isAssigned
                hExcSubPort=obj.getPort(exclusiveSubPortID);
                error(message('hdlcommon:interface:SubPortExclusive',...
                subPortID,hIOPort.PortName,...
                exclusiveSubPortID,obj.ChannelID,hExcSubPort.getAssignedPortName,...
                subPortID,exclusiveSubPortID));
            end


            if~hSubPort.MultipleAssignment
                if hSubPort.isAssigned&&...
                    ~hSubPort.isAssignedPortName(portName)
                    oldPortName=hSubPort.getAssignedPortName;
                    error(message('hdlcommon:interface:SubPortAssigned',subPortID,...
                    portName,oldPortName));
                end
            end


            if hIOPort.isBus
                if hSubPort.hDataType.isBusType

                    megStrRequired=message('hdlcommon:interface:StrRequired');
                    megStrModel=message('hdlcommon:interface:StrModel');
                    [isequal,msgObj]=hSubPort.hDataType.isTypeEqual(hIOPort.Type,...
                    megStrRequired.getString,megStrModel.getString);
                    if~isequal
                        if~isempty(msgObj)
                            msgStr=msgObj.getString;
                        else
                            msgStr='';
                        end
                        error(message('hdlcommon:interface:BusTypeMismatch',subPortID,portName,msgStr));
                    end
                else
                    error(message('hdlcommon:interface:BusUnsupportedForSubPort',subPortID));
                end
            else
                if hSubPort.hDataType.isBusType
                    error(message('hdlcommon:interface:BusNeededForSubPort',subPortID));
                end
            end


            portWidth=hIOPort.WordLength;
            if hSubPort.hDataType.isFlexibleWidth
                if portWidth>hSubPort.hDataType.getMaxWordLength
                    error(message('hdlcommon:interface:SubPortNotFit',...
                    subPortID,hSubPort.hDataType.getMaxWordLength,hIOPort.PortName,portWidth));
                end
            else
                if portWidth~=hSubPort.hDataType.getMaxWordLength
                    error(message('hdlcommon:interface:SubPortNotEqualWidth',...
                    subPortID,hSubPort.hDataType.getMaxWordLength,hIOPort.PortName,portWidth));
                end
            end
        end

        function validateCell=validateFullTable(obj,validateCell,hTable)


            cmdDisplay=hTable.hTurnkey.hD.cmdDisplay;
            isNonEmptyPortAssigned=obj.isNonEmptyPortAssigned;













            if~isNonEmptyPortAssigned||obj.isFrameModePort(hTable)

                if obj.getEmptyPort.isAssigned
                    assignedPortNameList=obj.getEmptyPort.getAssignedPortNameList;
                    for ii=1:length(assignedPortNameList)
                        modelPortName=assignedPortNameList{ii};
                        hIOPort=hTable.hIOPortList.getIOPort(modelPortName);
                        modelPortDir=hIOPort.PortType;
                        subPortIDList=obj.getPortIDListDir(modelPortDir);

                        validateCell{end+1}=downstream.tool.generateErrorWithStruct(...
                        message('hdlcommon:interface:SubPortNotSpecified',...
                        obj.ChannelID,modelPortName,...
                        sprintf('%s; ',subPortIDList{:})),cmdDisplay);%#ok<AGROW>
                    end
                end
                return;
            end



            subPortIDList=obj.getPortIDList;
            for ii=1:length(subPortIDList)
                subPortID=subPortIDList{ii};
                hPort=obj.getPort(subPortID);


                if hPort.IsRequiredPort&&~hPort.isAssigned&&...
                    ~obj.isExclusiveSubPortAssigned(subPortID)



                    validateCell{end+1}=downstream.tool.generateErrorWithStruct(...
                    message('hdlcommon:interface:SubPortRequired',...
                    subPortID,obj.ChannelID,obj.ChannelID),cmdDisplay);%#ok<AGROW>
                end
            end



            allportRate=0;
            for ii=1:length(subPortIDList)
                subPortID=subPortIDList{ii};
                hPort=obj.getPort(subPortID);

                if hPort.isAssigned&&~obj.isEmptyPort(hPort)
                    assignedPortName=hPort.getAssignedPortName;
                    hIOPort=hTable.hIOPortList.getIOPort(assignedPortName);
                    portRate=hIOPort.PortRate;
                    allportRate=obj.validatePortRate(assignedPortName,portRate,allportRate);
                end
            end
        end


        function initializeChannelElaboration(obj)



            obj.CodeGenPortNameList={};
        end

        function addCodeGenPortNamesToList(obj,codegenPortNames)

            for ii=1:length(codegenPortNames)
                obj.CodeGenPortNameList{end+1}=codegenPortNames{ii};
            end
        end

        function[multiRateCountEnable,multiRateCountValue]=getMultiRateInfo(obj,hDUTLayer,channelID,hChannelDir)
            dutBaseRate=hDUTLayer.DUTClockReportData.dutBaseRate;
            dutCodegenRateScaling=hDUTLayer.CodegenRateScaling;
            dutOriginalBaseRate=hDUTLayer.DUTOrigBaseRate;

            if(dutBaseRate==dutOriginalBaseRate)&&(dutCodegenRateScaling>1)
                dutBaseRate=dutBaseRate/dutCodegenRateScaling;
            end
            hCodegenIOPortList=hDUTLayer.getCodegenIOPortList;
            hCodegenInputPorts=hCodegenIOPortList.InputPortNameList;
            hCodegenOutputPorts=hCodegenIOPortList.OutputPortNameList;
            newChannelPort=[];
            for ii=1:length(hCodegenInputPorts)
                codegenPortDir=hCodegenIOPortList.getIOPort(hCodegenInputPorts{ii}).PortType;
                codegenPortInterface=hCodegenIOPortList.getIOPort(hCodegenInputPorts{ii}).IOInterface;
                if((codegenPortDir==hChannelDir)&&(~isempty(codegenPortInterface))&&isempty(newChannelPort))
                    if strcmp(codegenPortInterface,channelID)
                        newChannelPort=hCodegenInputPorts{ii};
                    end
                end
            end
            for ii=1:length(hCodegenOutputPorts)
                codegenPortDir=hCodegenIOPortList.getIOPort(hCodegenOutputPorts{ii}).PortType;
                codegenPortInterface=hCodegenIOPortList.getIOPort(hCodegenOutputPorts{ii}).IOInterface;
                if((codegenPortDir==hChannelDir)&&(~isempty(codegenPortInterface))&&isempty(newChannelPort))
                    if strcmp(codegenPortInterface,channelID)
                        newChannelPort=hCodegenOutputPorts{ii};
                    end
                end
            end


            if~isempty(newChannelPort)


                newCodegenPortName=strtrim(newChannelPort);
                hCodeGenIOPort=hCodegenIOPortList.getIOPort(newCodegenPortName);
                portRate=hCodeGenIOPort.PortRate;
                if dutBaseRate<portRate
                    multiRateCountEnable=1;
                    multiRateCountValue=portRate/dutBaseRate;

                    interfaceID='AXI4-Stream Video';
                    if contains(channelID,interfaceID)
                        error(message('hdlcommon:interface:AXI4StreamVideoSlowRate'));
                    end
                else
                    multiRateCountEnable=0;
                    multiRateCountValue=0;
                end
            else
                multiRateCountEnable=0;
                multiRateCountValue=0;
            end
        end


        function validateCodeGenPortRate(obj,hDUTLayer)





            dutBaseRate=hDUTLayer.DUTClockReportData.dutBaseRate;

            hCodegenIOPortList=hDUTLayer.getCodegenIOPortList;
            for ii=1:length(obj.CodeGenPortNameList)
                codegenPortName=obj.CodeGenPortNameList{ii};
                hCodeGenIOPort=hCodegenIOPortList.getIOPort(codegenPortName);

                portRate=hCodeGenIOPort.PortRate;

                if portRate~=dutBaseRate
                    error(message('hdlcommon:interface:ChannelInterfaceFastestRate',...
                    obj.ChannelID,codegenPortName,sprintf('%g',portRate),...
                    sprintf('%g',dutBaseRate)));
                end
            end
        end
    end

    methods(Access=protected)

        function allportRate=validatePortRate(obj,portName,portRate,allportRate)

            if allportRate==0
                allportRate=portRate;
            else
                if allportRate~=portRate
                    error(message('hdlcommon:interface:ChannelInterfaceSameRate',obj.ChannelID,portName));
                end
            end
        end

        function hPort=addEmptyPort(obj,subPortID)

            hPort=hdlturnkey.data.SubPortEmpty(subPortID);
            hEmptyType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',128);
            hPort.initilizePort('',...
            hEmptyType,false,'','',hdlturnkey.IOType.INOUT);
            hPort.MultipleAssignment=true;
            obj.addPortShared(subPortID,hPort);
        end

        function addPortShared(obj,subPortID,hPort)
            obj.SubPortMap(subPortID)=hPort;


            subPortIDStr=hPort.getPortIDDispStr;

            obj.SubPortIDList{end+1}=subPortIDStr;

            if hPort.PortDirType==hdlturnkey.IOType.IN
                obj.InputSubPortIDList{end+1}=subPortIDStr;
            elseif hPort.PortDirType==hdlturnkey.IOType.OUT
                obj.OutputSubPortIDList{end+1}=subPortIDStr;
            else
                obj.InputSubPortIDList{end+1}=subPortIDStr;
                obj.OutputSubPortIDList{end+1}=subPortIDStr;
            end
        end


        function subPortID=filterOptionalPostFix(obj,subPortIDStr)

            subPortID=regexprep(subPortIDStr,obj.OptionalPostFixRegExp,'','once');
        end

    end
end


