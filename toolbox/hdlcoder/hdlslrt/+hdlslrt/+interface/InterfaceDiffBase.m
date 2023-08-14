


classdef InterfaceDiffBase<hdlturnkey.interface.InterfaceIOBase


    properties


    end

    methods

        function obj=InterfaceDiffBase(interfaceID,interfaceType,portWidth,channelWidth,sharedAssignment)


            if nargin<5
                sharedAssignment=[];
            end

            if nargin<4
                channelWidth=portWidth/2;
            end

            obj=obj@hdlturnkey.interface.InterfaceIOBase(...
            interfaceID,interfaceType,portWidth,channelWidth,sharedAssignment);

        end

    end


    methods

    end


    methods

    end


    methods

    end


    methods

        function allocateUserSpecBitRange(obj,portName,hTableMap)



            bitRangeData=hTableMap.getBitRangeData(portName);
            channelIdxLSB=bitRangeData{1}+1;
            channelIdxMSB=bitRangeData{2}+1;
            portIdxLSB=channelIdxLSB*2-1;
            portIdxMSB=channelIdxMSB*2;


            [isAssigned,hViolateIOBit]=obj.AssignedBits.isBitRangeAssigned(portIdxLSB,portIdxMSB);
            if isAssigned

                channelViolate=floor((hViolateIOBit.BitIndex+1)/2);
                error(message('hdlcommon:workflow:DupSpec',channelViolate-1,portName,hViolateIOBit.AssignedPortName));
            end


            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            ioportType=hIOPort.PortType;
            obj.AssignedBits.setBitRangeAssigned(portIdxLSB,portIdxMSB,...
            portName,ioportType,obj.IOStandard,obj.InterfaceID);
        end

        function allocateDefaultBitRange(obj,portName,hTableMap)



            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            ioportWidth=hIOPort.WordLength;
            ioportType=hIOPort.PortType;


            [portIdxLSB,portIdxMSB]=obj.allocateConsecutiveBits(ioportWidth,ioportType,portName);


            channelIdxLSB=floor((portIdxLSB+1)/2);
            channelIdxMSB=floor((portIdxMSB)/2);


            obj.AssignedBits.setBitRangeAssigned(portIdxLSB,portIdxMSB,...
            portName,ioportType,obj.IOStandard,obj.InterfaceID);


            bitRangeData={channelIdxLSB-1,channelIdxMSB-1};
            hTableMap.setBitRangeData(portName,bitRangeData);
        end

        function[portIdxLSB,portIdxMSB]=allocateConsecutiveBits(obj,ioportWidth,ioportType,portName)

            idxStart=1;
            idxEnd=0;
            for ii=1:2:obj.AssignedBits.ArrayLength
                hIOBit=obj.AssignedBits.getIOBit(ii);
                hIOBitNext=obj.AssignedBits.getIOBit(ii+1);

                iobitType=hIOBit.getIOBitType(obj.IOStandard);
                iobitTypeNext=hIOBitNext.getIOBitType(obj.IOStandard);

                if hIOBit.Assigned||hIOBitNext.Assigned

                    idxStart=ii+2;

                elseif(iobitType~=hdlturnkey.IOType.INOUT&&iobitType~=ioportType)||...
                    (iobitTypeNext~=hdlturnkey.IOType.INOUT&&iobitTypeNext~=ioportType)

                    idxStart=ii+2;

                elseif ii-idxStart+2==ioportWidth*2
                    idxEnd=ii;
                    break;
                end
            end
            if idxEnd==0
                error(message('hdlcommon:workflow:UnableAutoAssign',ioportWidth,obj.InterfaceID,portName));
            end

            portIdxLSB=idxStart;
            portIdxMSB=idxEnd+1;
        end

    end


    methods

    end


    methods

    end


    methods

    end
end

