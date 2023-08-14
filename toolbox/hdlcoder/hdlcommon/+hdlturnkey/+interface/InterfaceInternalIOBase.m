





















classdef(Abstract)InterfaceInternalIOBase<hdlturnkey.interface.InterfaceBase&...
    hdlturnkey.interface.IPWorkflowBase

    properties


        PortName='';


        InterfaceConnection='';


        PortWidth=0;

    end

    properties(Hidden=true)

        ChannelWidth=0;


        AssignedBits=[];


        DutInputPortList={};
        DutOutputPortList={};


        IOStandard='';
    end

    methods

        function obj=InterfaceInternalIOBase(varargin)


            p=inputParser;
            p.addParameter('InterfaceID','');
            p.addParameter('InterfaceType','');
            p.addParameter('PortName','');
            p.addParameter('PortWidth',0);
            p.addParameter('InterfaceConnection','');


            p.addParameter('IsRequired',true);

            p.parse(varargin{:});
            inputArgs=p.Results;

            obj=obj@hdlturnkey.interface.InterfaceBase(...
            inputArgs.InterfaceID);


            obj.PortWidth=inputArgs.PortWidth;
            obj.ChannelWidth=inputArgs.PortWidth;

            if strcmpi(inputArgs.InterfaceType,'IN')
                obj.InterfaceType=hdlturnkey.IOType.IN;
            elseif strcmpi(inputArgs.InterfaceType,'OUT')
                obj.InterfaceType=hdlturnkey.IOType.OUT;
            elseif strcmpi(inputArgs.InterfaceType,'INOUT')
                obj.InterfaceType=hdlturnkey.IOType.INOUT;
            else
                error(message('hdlcommon:workflow:InvalidInterfaceType',interfaceType));
            end

            obj.PortName=inputArgs.PortName;
            obj.InterfaceConnection=inputArgs.InterfaceConnection;
            obj.IsRequired=inputArgs.IsRequired;

            sharedAssignment=[];


            obj.initInterfaceAssignement(sharedAssignment);
        end

    end


    methods

        function validateInterface(obj)


            validateInterface@hdlturnkey.interface.InterfaceBase(obj);

            if obj.PortWidth<=0||obj.ChannelWidth<=0
                error(message('hdlcommon:workflow:ZeroPortWidth',obj.InterfaceID));
            end
        end

        function initInterfaceAssignement(obj,sharedAssignment)


            if nargin<1
                sharedAssignment=[];
            end

            if~isempty(sharedAssignment)

                obj.AssignedBits=sharedAssignment;
            else

                obj.AssignedBits=hdlturnkey.data.IOBitList(obj.PortWidth);
            end


            for ii=1:obj.AssignedBits.ArrayLength
                hIOBit=obj.AssignedBits.getIOBit(ii);
                hIOBit.setIOBitType(obj.InterfaceType,obj.IOStandard);
            end
        end

        function cleanInterfaceAssignment(obj,~)

            obj.AssignedBits.cleanAssignment;
        end


        function validatePortForInterfaceShared(obj,hIOPort,~,interfaceStr)



            if hIOPort.isHalf
                error(message('hdlcommon:workflow:HalfPortUnsupported',interfaceStr,hIOPort.PortName));
            end


            if hIOPort.isSingle
                error(message('hdlcommon:workflow:SinglePortUnsupported',interfaceStr,hIOPort.PortName));
            end


            if hIOPort.isBus
                error(message('hdlcommon:workflow:UnsupportedBusPort',...
                interfaceStr,hIOPort.PortName));
            end


            portDirType=hIOPort.PortType;
            interfaceDirType=obj.InterfaceType;
            if interfaceDirType~=hdlturnkey.IOType.INOUT&&portDirType~=interfaceDirType
                error(message('hdlcommon:interface:PortTypeNotMatch',interfaceStr,...
                downstream.tool.getPortDirTypeStr(interfaceDirType),...
                downstream.tool.getPortDirTypeStr(portDirType),hIOPort.PortName));
            end
        end
    end


    methods
        function assignBitRange(obj,portName,bitRangeStr,hTableMap)


            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            [idxLSB,idxMSB]=obj.parseBitRangeStr(hIOPort,bitRangeStr);


            bitRangeData={idxLSB,idxMSB};
            hTableMap.setBitRangeData(portName,bitRangeData);
        end

        function[idxLSB,idxMSB]=parseBitRangeStr(obj,hIOPort,bitRangeStr)



            [idxLSB,idxMSB]=obj.parseBitRangeStrShared(bitRangeStr);


            bitrangeWidth=idxMSB-idxLSB+1;
            IOPortFlattenedPortWidth=hIOPort.getFlattenedPortWidth;
            if bitrangeWidth~=IOPortFlattenedPortWidth
                error(message('hdlcommon:workflow:OutPortWidthBound',bitRangeStr,bitrangeWidth,hIOPort.PortName,IOPortFlattenedPortWidth));
            end

        end

        function[idxLSB,idxMSB]=parseBitRangeStrShared(obj,bitRangeStr)

            try
                bitrange=eval(bitRangeStr);
            catch ME
                error(message('hdlcommon:workflow:InvalidBitRangeinput',ME.message));
            end

            if iscell(bitrange)
                error(message('hdlcommon:workflow:BitRangeCellUnsup'));
            end


            if isempty(bitrange)
                error(message('hdlcommon:workflow:InvalidArrayDimension',bitRangeStr));
            end
            if length(bitrange)==1
                idxLSB=bitrange;
                idxMSB=bitrange;
            else
                idxLSB=bitrange(1);
                idxMSB=bitrange(end);

                if idxLSB>=idxMSB
                    error(message('hdlcommon:workflow:RangeReversed'));
                end


                if idxMSB-idxLSB+1~=length(bitrange)
                    error(message('hdlcommon:workflow:NonConsecutiveBitRange'));
                end
            end


            if idxLSB<0||idxMSB>obj.ChannelWidth-1||idxMSB-idxLSB+1>obj.ChannelWidth
                error(message('hdlcommon:workflow:OutInterfaceBound',bitRangeStr,obj.ChannelWidth-1,obj.InterfaceID,obj.ChannelWidth));
            end
        end


        function validatePortForInterface(obj,hIOPort,~)



            portWidth=hIOPort.WordLength;
            interfaceWidth=obj.ChannelWidth;
            portDimension=hIOPort.Dimension;


            if(portWidth*portDimension~=interfaceWidth)
                error(message('hdlcommon:interface:InterfaceNotEqualWidth',...
                obj.InterfaceID,obj.ChannelWidth,hIOPort.PortName,portWidth*portDimension));
            end


            if(portWidth*portDimension>65535)
                error(message('hdlcommon:workflow:VectorPortBitWidthLargerThan65535Bits',...
                obj.InterfaceID,portWidth*portDimension,hIOPort.PortName));
            end
        end
    end


    methods

        function interfaceStr=getTableCellInterfaceStr(obj,~)

            if obj.ChannelWidth>1
                interfaceStr=sprintf('%s [%d:%d]',...
                obj.InterfaceID,0,obj.ChannelWidth-1);
            else
                interfaceStr=sprintf('%s',obj.InterfaceID);
            end
        end

        function bitRangeStr=getTableCellBitRangeStr(~,portName,hTableMap)

            bitRangeData=hTableMap.getBitRangeData(portName);
            bitRangeLSB=bitRangeData{1};
            bitRangeMSB=bitRangeData{2};
            if bitRangeLSB==bitRangeMSB
                bitRangeStr=sprintf('[%d]',bitRangeLSB);
            else
                bitRangeStr=sprintf('[%d:%d]',bitRangeLSB,bitRangeMSB);
            end
        end
    end


    methods

        function allocateUserSpecBitRange(obj,portName,hTableMap)



            bitRangeData=hTableMap.getBitRangeData(portName);
            portIdxLSB=bitRangeData{1}+1;
            portIdxMSB=bitRangeData{2}+1;


            [isAssigned,hViolateIOBit]=obj.AssignedBits.isBitRangeAssigned(portIdxLSB,portIdxMSB);
            if isAssigned

                error(message('hdlcommon:workflow:BitDupSpec',hViolateIOBit.BitIndex-1,portName,hViolateIOBit.AssignedPortName));
            end


            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            ioportType=hIOPort.PortType;
            obj.AssignedBits.setBitRangeAssigned(portIdxLSB,portIdxMSB,...
            portName,ioportType,obj.IOStandard,obj.InterfaceID);
        end

        function allocateDefaultBitRange(obj,portName,hTableMap)



            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            ioportWidth=hIOPort.getFlattenedPortWidth;
            ioportType=hIOPort.PortType;


            [portIdxLSB,portIdxMSB]=obj.allocateConsecutiveBits(ioportWidth,ioportType,portName);


            obj.AssignedBits.setBitRangeAssigned(portIdxLSB,portIdxMSB,...
            portName,ioportType,obj.IOStandard,obj.InterfaceID);


            bitRangeData={portIdxLSB-1,portIdxMSB-1};
            hTableMap.setBitRangeData(portName,bitRangeData);
        end

        function[portIdxLSB,portIdxMSB]=allocateConsecutiveBits(obj,ioportWidth,ioportType,portName)

            idxStart=1;
            idxEnd=0;
            for ii=1:obj.AssignedBits.ArrayLength
                hIOBit=obj.AssignedBits.getIOBit(ii);
                iobitType=hIOBit.getIOBitType(obj.IOStandard);

                if hIOBit.Assigned

                    idxStart=ii+1;

                elseif iobitType~=hdlturnkey.IOType.INOUT&&iobitType~=ioportType

                    idxStart=ii+1;

                elseif ii-idxStart+1==ioportWidth
                    idxEnd=ii;
                    break;
                end
            end
            if idxEnd==0
                error(message('hdlcommon:workflow:UnableAutoAssignBit',ioportWidth,obj.InterfaceID,portName));
            end

            portIdxLSB=idxStart;
            portIdxMSB=idxEnd;
        end
    end


    methods

        function elaborate(obj,hN,hElab)


            hInterfaceSignal=obj.addInterfacePort(hN);


            obj.connectInterfacePort(hN,hElab,hInterfaceSignal);

        end




        function connectInterfacePort(obj,hN,hElab,hIPSignals)




            getSortedDutInputOutputIOPort(obj);


            switch(obj.InterfaceType)
            case hdlturnkey.IOType.IN
                obj.connectInputInterfacePort(hN,hElab,hIPSignals);
            case hdlturnkey.IOType.OUT
                obj.connectOutputInterfacePort(hN,hElab,hIPSignals);
            end
        end
        function connectInputInterfacePort(obj,hN,hElab,hInterfaceSignal)



            hInportSignals=hInterfaceSignal.hInportSignals;


            for ii=1:length(obj.DutInputPortList)
                dutPortName=obj.DutInputPortList{ii};



                hDutPortSignals=hElab.getCodegenPirSignalForPort(dutPortName);


                bitRangeData=hElab.hTurnkey.hTable.hTableMap.getBitRangeData(dutPortName);
                bitRangeLSB=bitRangeData{1};
                bitRangeMSB=bitRangeData{2};


                hIOPort=hElab.hTurnkey.hTable.hIOPortList.getIOPort(dutPortName);
                portwidth=hIOPort.WordLength;



                assert(hIOPort.getFlattenedPortWidth==bitRangeMSB-bitRangeLSB+1,...
                'Bit Range Specified does not match with the Port width mentioned');



                sliceLSB=bitRangeLSB;
                sliceMSB=bitRangeLSB+portwidth-1;



                for i=1:numel(hDutPortSignals)

                    pirtarget.getInPortBitSliceComp(hN,hInportSignals,hDutPortSignals{i},sliceMSB,sliceLSB);






                    sliceLSB=sliceMSB+1;
                    sliceMSB=sliceMSB+portwidth;
                end
            end
        end

        function connectOutputInterfacePort(obj,hN,hElab,hInterfaceSignal)



            hOutportSignals=hInterfaceSignal.hOutportSignals;


            hInSignals={};
            constStart=0;
            for ii=1:length(obj.DutOutputPortList)
                dutPortName=obj.DutOutputPortList{ii};


                hDutPortSignals=hElab.getCodegenPirSignalForPort(dutPortName);
                hDutPortSignal=hDutPortSignals{1};


                bitRangeData=hElab.hTurnkey.hTable.hTableMap.getBitRangeData(dutPortName);
                bitRangeLSB=bitRangeData{1};
                bitRangeMSB=bitRangeData{2};



                if bitRangeLSB>constStart
                    constBitWidth=bitRangeLSB-constStart;
                    constSignal=obj.getConstSignal(hN,constBitWidth);
                    hInSignals{1,end+1}=constSignal;%#ok<*AGROW>                    
                end
                constStart=bitRangeMSB+1;









                hInSignals=[hInSignals,hDutPortSignals'];
            end


            if obj.ChannelWidth>constStart
                constBitWidth=obj.ChannelWidth-constStart;
                constSignal=obj.getConstSignal(hN,constBitWidth);
                hInSignals{1,end+1}=constSignal;
            end


            pirtarget.getOutPortBitConcatComp(hN,hInSignals,hOutportSignals);

        end

        function getSortedDutInputOutputIOPort(obj)



            obj.DutInputPortList={};
            obj.DutOutputPortList={};
            for ii=1:obj.AssignedBits.ArrayLength
                hIOBit=obj.AssignedBits.getIOBit(ii);

                if hIOBit.Assigned&&...
                    strcmpi(hIOBit.AssignedInterfaceID,obj.InterfaceID)

                    portType=hIOBit.AssignedPortType;
                    portName=hIOBit.AssignedPortName;

                    if portType==hdlturnkey.IOType.IN&&...
                        ~any(strcmpi(obj.DutInputPortList,portName))
                        obj.DutInputPortList{end+1}=portName;

                    elseif portType==hdlturnkey.IOType.OUT&&...
                        ~any(strcmpi(obj.DutOutputPortList,portName))
                        obj.DutOutputPortList{end+1}=portName;
                    end

                end
            end
        end
        function populatePortNameWidthFromAssignedBits(obj)


            obj.InportNames={};
            obj.InportWidths={};
            obj.OutportNames={};
            obj.OutportWidths={};

            for ii=1:obj.AssignedBits.ArrayLength
                hIOBit=obj.AssignedBits.getIOBit(ii);

                if hIOBit.Assigned&&...
                    strcmpi(hIOBit.AssignedInterfaceID,obj.InterfaceID)

                    portType=hIOBit.AssignedPortType;
                    iobitPortName=hIOBit.IOBitPortName;

                    if portType==hdlturnkey.IOType.IN
                        obj.InportNames{end+1}=iobitPortName;
                        obj.InportWidths{end+1}=1;
                    else
                        obj.OutportNames{end+1}=iobitPortName;
                        obj.OutportWidths{end+1}=1;
                    end
                end
            end
        end

        function[inportIdx,outportIdx]=getAssignedBitsIndex(obj)


            inportIdx={};
            outportIdx={};

            for ii=1:obj.AssignedBits.ArrayLength
                hIOBit=obj.AssignedBits.getIOBit(ii);

                if hIOBit.Assigned&&...
                    strcmpi(hIOBit.AssignedInterfaceID,obj.InterfaceID)

                    portType=hIOBit.AssignedPortType;
                    portIdx=hIOBit.BitIndex;

                    if portType==hdlturnkey.IOType.IN
                        inportIdx{end+1}=portIdx;
                    else
                        outportIdx{end+1}=portIdx;
                    end
                end
            end
        end

        function hInterfaceSignal=addInterfacePort(obj,hN)



            obj.InportNames={};
            obj.InportWidths={};
            obj.OutportNames={};
            obj.OutportWidths={};



            obj.getSortedDutInputOutputIOPort;

            if isempty(obj.DutInputPortList)





                obj.OutportNames{1}=obj.PortName;
                obj.OutportWidths{1}=obj.PortWidth;

            elseif isempty(obj.DutOutputPortList)




                obj.InportNames{1}=obj.PortName;
                obj.InportWidths{1}=obj.PortWidth;

            end


            hInterfaceSignal=pirelab.addIOPortToNetwork(...
            'Network',hN,...
            'InportNames',obj.InportNames,...
            'InportWidths',obj.InportWidths,...
            'OutportNames',obj.OutportNames,...
            'OutportWidths',obj.OutportWidths);
        end

        function isa=isIPCoreClockNeeded(~)
            isa=false;
        end

    end


    methods

        function populateFPGAPinMapFromAssignedBits(obj)


            obj.FPGAPinMap={};

            for ii=1:obj.AssignedBits.ArrayLength
                hIOBit=obj.AssignedBits.getIOBit(ii);

                if hIOBit.Assigned&&...
                    strcmpi(hIOBit.AssignedInterfaceID,obj.InterfaceID)

                    iobitPortName=hIOBit.IOBitPortName;
                    iobitPinName=hIOBit.IOBitPinName;
                    ioStandard=sprintf('IOSTANDARD = %s',hIOBit.AssignedIOStandard);

                    pinMapping={iobitPortName,iobitPinName,ioStandard};
                    obj.FPGAPinMap{end+1}=pinMapping;
                end
            end
        end
    end


    methods
        function isa=isIPInternalIOInterface(obj)%#ok<MANU>
            isa=true;
        end

    end

    methods(Static)

        function[isa,hIFCell,hIOPortCell]=isInternalIOInterfaceAssigned(hTurnkey)

            isa=false;
            hIOPortCell={};
            hIFCell={};
            interfaceIDList=hTurnkey.hTable.hTableMap.getAssignedInterfaces;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);
                if hInterface.isIPInternalIOInterface
                    portNames=hTurnkey.hTable.hTableMap.getConnectedPortList(interfaceID);
                    isa=true;
                    hIFCell{end+1}=hInterface;%#ok<AGROW>
                    for i=1:length(portNames)
                        hIOPortCell{end+1}=hTurnkey.hTable.hIOPortList.getIOPort(portNames{i});
                    end
                end
            end
        end
    end

    methods

        function getChannelBasedOutPortConcatComp(obj,hN,channelWidth,...
            channelNums,channelSigs,outportSig)

            hInSignals={};
            constStart=0;
            for ii=1:length(channelNums)
                channelNum=channelNums{ii};
                channelSig=channelSigs{ii};


                if channelNum>constStart
                    constBitWidth=channelNum-constStart;
                    constZeroSignal=obj.getConstZeroSignal(hN,constBitWidth);
                    hInSignals{end+1}=constZeroSignal;%#ok<*AGROW>
                end
                constStart=channelNum+1;


                hInSignals{end+1}=channelSig;
            end


            if channelWidth>constStart
                constBitWidth=channelWidth-constStart;
                constZeroSignal=obj.getConstZeroSignal(hN,constBitWidth);
                hInSignals{end+1}=constZeroSignal;
            end


            pirtarget.getOutPortBitConcatComp(hN,hInSignals,outportSig);
        end

        function constSignal=getConstSignal(obj,hN,constBitWidth)


            if obj.isIPInterface&&obj.isIPExternalIOInterface


                constSignal=obj.getConstZeroSignal(hN,constBitWidth);
            else

                constSignal=obj.getConstZSignal(hN,constBitWidth);
            end
        end

        function constZSignal=getConstZSignal(~,hN,constBitWidth)%#ok<*MANU>

            constType=pir_ufixpt_t(constBitWidth,0);
            constZSignal=hN.addSignal(constType,'const_z');
            pirelab.getConstSpecialComp(hN,constZSignal,'Z');
        end

        function constZeroSignal=getConstZeroSignal(~,hN,constBitWidth)

            constType=pir_ufixpt_t(constBitWidth,0);
            constZeroSignal=hN.addSignal(constType,'const_zero');
            pirelab.getConstComp(hN,constZeroSignal,0);
        end

        function constOneSignal=getConstOneSignal(~,hN,constBitWidth)

            constType=pir_ufixpt_t(constBitWidth,0);
            constOneSignal=hN.addSignal(constType,'const_one');
            pirelab.getConstComp(hN,constOneSignal,1);
        end

    end
end



