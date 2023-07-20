



classdef(Abstract)InterfaceBase<matlab.mixin.SetGetExactNames


    properties(SetAccess=protected)



        InterfaceID='';
        InterfaceType=hdlturnkey.IOType.INOUT;


        HelpDocID='';

    end

    properties(Hidden=true)


        IsRequired=false;


        IsGenericIP=false;


        InportNames={};
        InportWidths={};
        OutportNames={};
        OutportWidths={};
        DUTInportNames={};
        DUTOutportNames={};


        isConstrainAttached=false;



        isFixedInWrapper=false;


        InterfaceIPName='';
        InterfaceIPFiles={};










        FPGAPinMap={};



        SupportedTool={};
        SupportedLiberoFamily={};


        isDefaultBusInterfaceRequired=false;
        SoftwareInterface;
        HostInterface;
    end

    methods

        function obj=InterfaceBase(interfaceID)


            obj.InterfaceID=interfaceID;

        end


        function isa=isIPExternalInterface(~)
            isa=false;
        end

        function isa=isIPExternalIOInterface(~)
            isa=false;
        end

        function isa=isIPInternalIOInterface(~)
            isa=false;
        end

        function isa=isAXI4SlaveInterface(obj)
            isa=false;
        end

        function isa=isAXI4Interface(obj)
            isa=false;
        end

        function isa=isAXI4LiteInterface(obj)
            isa=false;
        end

        function isa=isEmptyInterface(obj)
            isa=false;
        end

        function isa=isEmptyAXI4SlaveInterface(obj)
            isa=false;
        end

        function isa=isPCIInterface(obj)
            isa=false;
        end

        function isa=isAddrBasedInterface(obj)
            isa=false;
        end

        function isa=isStreamBasedVDMAInterface(obj)
            isa=false;
        end

        function isa=isADBasedInterface(obj)
            isa=false;
        end

        function isa=isBitRangeComboBox(obj,portName,hTableMap)

            isa=false;
        end

        function isa=showInterfaceOptionPushButton(obj,hIOPort,hTableMap)

            optionIDList=obj.getInterfaceOptionList(hIOPort.PortName,hTableMap);

            isa=~isempty(optionIDList)&&~hIOPort.isTunable&&~hIOPort.isTestPoint;
        end


        function isa=isIPInterface(~)
            isa=false;
        end

    end


    methods
        function validateInterface(obj)

            if isempty(obj.InterfaceID)
                error(message('hdlcommon:workflow:EmptyID',class(obj)));
            end
        end

        function validateInterfaceForTool(obj,toolName)

        end

        function validateInterfaceForReferenceDesign(obj,hRD)

        end

        function cleanInterfaceAssignment(obj,hTable)%#ok<*MANU>

        end

        function cleanInterfaceChannelAssignment(obj)

        end

        function vOut=castToPortDatatype(obj,vIn,hPort)

            if(hPort.isSingle||hPort.isDouble)

                vOut=cast(vIn,hPort.SLDataType);
            else

                vOut=cast(vIn,'like',fi([],hPort.Signed,hPort.WordLength,-hPort.FractionLength));
            end
        end

        function vOut=castToRegDatatype(obj,vIn,hAddr)

            if(strcmp(hAddr.DataType.SLType,'single')||strcmp(hAddr.DataType.SLType,'double'))

                vOut=cast(vIn,hAddr.DataType.SLType);
            else

                vOut=cast(vIn,'like',fi([],hAddr.DataType.Signed,hAddr.DataType.WordLength,-hAddr.DataType.FractionLength));
            end
        end

        function[optValue,optValueName]=parseInterfaceOption(obj,portName,hTableMap,option,defaultValue)

            interfaceOpt=hTableMap.getInterfaceOption(portName);


            p=inputParser;

            optionIDList=obj.getInterfaceOptionList(portName,hTableMap);
            for i=1:length(optionIDList)
                if(strcmp(optionIDList{i},option))
                    p.addParameter(optionIDList{i},defaultValue);
                else
                    p.addParameter(optionIDList{i},'0');
                end
            end
            p.parse(interfaceOpt{:});
            interfaceOpt=p.Results;


            if~isfield(interfaceOpt,option)
                optValue=defaultValue;
                optValueName=option;
                return;
            else
                optValueName=getfield(interfaceOpt,option);
            end

            if~strcmp(option,'SamplePackingDimension')&&~strcmp(option,'PackingMode')
                try
                    optValue=evalin('base',optValueName);
                catch me
                    error(message('hdlcommon:workflow:InvalidInterfaceOption',optValueName,option));
                end
            else
                optValue=optValueName;
            end

        end
    end


    methods
        function assignInterface(obj,portName,interfaceStr,hTableMap)



            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            obj.validatePortForInterfaceFrameToSample(hIOPort,hTableMap,interfaceStr);
            obj.validatePortForInterfaceShared(hIOPort,hTableMap,interfaceStr);
            obj.validatePortForInterface(hIOPort,hTableMap);


            obj.assignInterfaceBase(portName,hTableMap);
        end

        function assignInterfaceBase(obj,portName,hTableMap)



            previousObj=hTableMap.getInterface(portName);
            if isequal(obj,previousObj)
                return;
            end

            hTableMap.setInterface(portName,obj);

            hTableMap.initialBitRangeData(portName);

            hTableMap.initialInterfaceOption(portName);
        end

        function finishAssignInterface(obj,hTurnkey)

        end

        function assignBitRange(obj,portName,bitRangeStr,hTableMap)%#ok<*INUSD,*INUSL>


            if~isempty(bitRangeStr)
                error(message('hdlcommon:workflow:BitRangeNotSupported',obj.InterfaceID));
            end
        end

        function assignInterfaceOption(obj,portName,optParamPVPair,hTableMap)%#ok<*INUSD,*INUSL>

            if~isempty(optParamPVPair)
                error(message('hdlcommon:workflow:InterfaceOptionsNotSupported',obj.InterfaceID));
            end
        end

        function validatePortForInterfaceShared(~,hIOPort,~,interfaceStr)





            if hIOPort.isBus
                error(message('hdlcommon:workflow:UnsupportedBusPort',...
                interfaceStr,hIOPort.PortName));
            end



            if hIOPort.isComplex
                error(message('hdlcommon:workflow:UnsupportedComplexPort',interfaceStr,hIOPort.PortName));
            end

        end

        function validatePortForInterfaceFrameToSample(obj,hIOPort,hTableMap,interfaceStr)

            if(obj.isEmptyInterface)
                return;
            end




            if hTableMap.hTable.hTurnkey.hStream.isFrameToSampleMode&&...
                hIOPort.isStreamedPort
                error(message('hdlcommon:workflow:UnsupportedFramePort',...
                interfaceStr,hIOPort.PortName));

            end
        end

        function validatePortForInterface(obj,hIOPort,hTableMap)

        end

        function validateCell=validateFullTable(obj,validateCell,hTable)

        end

        function result=showInInterfaceChoice(~,hTurnkey)

            result=true;
        end

        function[needError,msgObj]=validateRequiredInterface(obj,hTableMap)

            needError=false;
            msgObj=[];
            if obj.IsRequired&&...
                ~hTableMap.isAssignedInterface(obj.InterfaceID)
                msgObj=message('hdlcommon:hdlturnkey:RequiredInterfaceNotAssigned',...
                obj.InterfaceID);
                needError=true;
            end
        end
    end


    methods

        function interfaceStr=getTableCellInterfaceStr(obj,portName)

            interfaceStr=obj.InterfaceID;
        end

        function[inputInterfaceStrList,outputInterfaceStrList]=getTableInterfaceStrList(obj)

            inputInterfaceStrList={obj.getTableCellInterfaceStr};
            outputInterfaceStrList={obj.getTableCellInterfaceStr};
        end

        function bitrangeStr=getTableCellBitRangeStr(obj,portName,hTableMap)

            bitrangeStr='';
        end

        function interfaceOptStr=getTableCellInterfaceOptionStr(obj,portName,hTableMap)
            interfaceOptStr='';

            if(hTableMap.isInterfaceOptionUserSpec(portName))
                interfaceOptStr=hTableMap.getInterfaceOption(portName);
                interfaceOptStr=strjoin(interfaceOptStr);
            end
        end
    end


    methods

        function allocateUserSpecBitRange(obj,portName,hTableMap)



        end

        function allocateDefaultBitRange(obj,portName,hTableMap)



        end

    end


    methods
        function allocateUserSpecInterfaceOption(obj,portName,hTableMap)



        end

        function optionIDList=getInterfaceOptionList(obj,portName,hTableMap)

            optionIDList={};
        end

        function optionValue=getInterfaceOptionValue(obj,portName,optionID)

            optionValue=[];
        end

        function optionStr=getInterfaceOptionStr(obj,optionID)


            optionStr=optionID;
        end

        function optionChoices=getInterfaceOptionChoices(obj,portName,optionID)

            optionChoices={};
        end

        function validateInterfaceOption(obj,portName,interfaceOpt)



        end


        function id=getHelpDocID(obj)
            id=obj.HelpDocID;
        end
    end


    methods(Abstract)



        elaborate(obj,hN,hElab)
    end

    methods

        function hInterfaceSignal=addInterfacePort(obj,hN)

            hInterfaceSignal=pirelab.addIOPortToNetwork(...
            'Network',hN,...
            'InportNames',obj.InportNames,...
            'InportWidths',obj.InportWidths,...
            'OutportNames',obj.OutportNames,...
            'OutportWidths',obj.OutportWidths);
        end

        function initializeInterfaceElaborationBegin(obj)

        end

        function registerAddress(obj,hElab)


        end

        function registerAddressAuto(obj,hElab)


        end

        function[isNeeded,dut_enb_signal]=scheduleDUTEnableWiring(obj,hN,hElab)

            isNeeded=false;
            dut_enb_signal=[];
        end

        function hBus=getDefaultBusInterface(obj,hElab)

            hBus=hElab.getDefaultBusInterface;
        end

    end


    methods
        function constrainCell=generateFPGAPinConstrain(obj,~)






            constrainCell=obj.getFPGAPinConstraintCell;
        end

        function generateInterfaceSpecificConstrain(obj,fid,hElab)

        end

    end


    methods
        function copyInterfaceIPFiles(obj,hTurnkey)

            if~isempty(obj.InterfaceIPFiles)

                classPackage=class(obj);


                interfaceFileFullPath=which(classPackage);
                interfaceDir=fileparts(interfaceFileFullPath);

                codegenDir=hTurnkey.hD.hCodeGen.CodegenDir;

                for ii=1:length(obj.InterfaceIPFiles)
                    interfaceIPFileName=obj.InterfaceIPFiles{ii};
                    sourcePath=fullfile(interfaceDir,interfaceIPFileName);

                    targetPath=fullfile(codegenDir,interfaceIPFileName);

                    copyfile(sourcePath,targetPath,'f');
                    hTurnkey.TurnkeyFileList{end+1}=interfaceIPFileName;
                end
            end
        end
    end


    methods(Access=public,Hidden)
        function hSoftwareInterface=getSoftwareInterface(obj,hTurnkey)

            hSoftwareInterface=obj.SoftwareInterface;



            if isempty(hSoftwareInterface)
                hSoftwareInterface=obj.getDefaultSoftwareInterface(hTurnkey);
            end
        end

        function hHostInterface=getHostInterface(obj,hTurnkey)

            hHostInterface=obj.HostInterface;



            if isempty(hHostInterface)
                hHostInterface=obj.getDefaultHostInterface(hTurnkey);
            end
        end

        function hHostInterface=getDefaultSoftwareInterface(obj,hTurnkey)
            hHostInterface=hdlturnkey.swinterface.SoftwareInterfaceEmpty(obj.InterfaceID);
        end

        function hHostInterface=getDefaultHostInterface(obj,hTurnkey)
            hHostInterface=hdlturnkey.swinterface.SoftwareInterfaceEmpty(obj.InterfaceID);
        end

        function runInterfaceSpecificModelGeneration(obj,hModelGen)

        end
    end


    methods
        function inuse=isInterfaceInUse(obj,hTurnkey)




            inuse=obj.isFixedInWrapper||...
            hTurnkey.isAssignedInterface(obj.InterfaceID)||...
            hTurnkey.isDefaultBusInterface(obj);
        end
    end


    methods(Access=protected)

        function constrainCell=getFPGAPinConstraintCell(obj)














            if isempty(obj.FPGAPinMap)
                constrainCell={};
                return;
            end


            if~iscell(obj.FPGAPinMap)
                error(message('hdlcommon:hdlturnkey:InvalidFPGAPinMap',obj.InterfaceID,...
                '{''PortName'', {''Pin1'', ''Pin2''}, ''ioStandard''}'));
            end


            constrainCell={};
            for ii=1:length(obj.FPGAPinMap)
                pinMapPair=obj.FPGAPinMap{ii};
                portName=pinMapPair{1};
                pinName=pinMapPair{2};
                if length(pinMapPair)>2
                    ioPadConstrain=pinMapPair{3};
                else
                    ioPadConstrain={};
                end

                if~iscell(pinName)
                    pinName={pinName};
                end
                if~iscell(ioPadConstrain)
                    ioPadConstrain={ioPadConstrain};
                end



                if obj.isIOPadConstrainPinSpecific(ioPadConstrain)

                    for jj=1:length(pinName)
                        pinMapping=obj.getFPGAPinMapping(length(pinName),portName,jj-1,pinName{jj},ioPadConstrain{jj});
                        constrainCell{end+1}=pinMapping;%#ok<AGROW>
                    end
                else

                    for jj=1:length(pinName)
                        pinMapping=obj.getFPGAPinMapping(length(pinName),portName,jj-1,pinName{jj},ioPadConstrain);
                        constrainCell{end+1}=pinMapping;%#ok<AGROW>
                    end
                end
            end
        end

        function pinMapping=getFPGAPinMapping(~,portWidth,portNameStr,portIdx,fpgaPinStr,ioPadConstrain)

            if nargin<6
                ioPadConstrain={};
            end

            if portWidth==1
                dutPortStr=portNameStr;
            else
                dutPortStr=sprintf('%s<%d>',portNameStr,portIdx);
            end


            pinMapping={dutPortStr,fpgaPinStr};



            if~isempty(ioPadConstrain)
                pinMapping=[pinMapping,ioPadConstrain];
            end
        end

        function status=isIOPadConstrainPinSpecific(~,constraintCell)



            status=false;
            if isempty(constraintCell)
                return;
            end
            iopadElement=constraintCell{1};
            if iscell(iopadElement)
                status=true;
            end
        end

    end

    methods(Static,Access=protected)
        function isit=isToolISE(toolName)

            isit=hdlturnkey.plugin.ReferenceDesign.isToolISE(toolName);
        end

        function isit=isToolVivado(toolName)

            isit=hdlturnkey.plugin.ReferenceDesign.isToolVivado(toolName);
        end

        function isit=isToolQuartus(toolName)

            isit=hdlturnkey.plugin.ReferenceDesign.isToolQuartus(toolName);
        end

        function isit=isToolQuartusPro(toolName)

            isit=hdlturnkey.plugin.ReferenceDesign.isToolQuartusPro(toolName);
        end

        function validateDeviceTreeNodeName(nodeName,propName,exampleStr)
            hdlturnkey.plugin.validateStringProperty(...
            nodeName,propName,exampleStr);

            if~isempty(nodeName)

                matlabshared.devicetree.util.validateReferenceName(nodeName);
            end
        end
    end
end



