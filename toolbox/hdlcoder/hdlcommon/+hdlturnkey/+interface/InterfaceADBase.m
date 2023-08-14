


classdef InterfaceADBase<hdlturnkey.interface.InterfaceIOBase


    properties

    end

    methods

        function obj=InterfaceADBase(varargin)


            obj=obj@hdlturnkey.interface.InterfaceIOBase(varargin{:});




        end

        function isa=isADBasedInterface(obj)%#ok<MANU>
            isa=true;
        end

    end


    methods

    end


    methods

        function[idxLSB,idxMSB]=parseBitRangeStr(obj,~,bitRangeStr)



            [idxLSB,idxMSB]=obj.parseBitRangeStrShared(bitRangeStr);


            bitrangeWidth=idxMSB-idxLSB+1;
            if bitrangeWidth~=1
                error(message('hdlcommon:workflow:OneChannelInput',obj.InterfaceID));
            end

        end

        function validatePortForInterface(obj,hIOPort,~)



            portWidth=hIOPort.WordLength;
            isSigned=hIOPort.Signed;
            if portWidth~=16||~isSigned
                error(message('hdlcommon:workflow:BitWidthNot16Bit',obj.InterfaceID));
            end

        end

    end


    methods

    end


    methods

        function allocateDefaultBitRange(obj,portName,hTableMap)



            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            ioportType=hIOPort.PortType;


            [portIdxLSB,portIdxMSB]=obj.allocateConsecutiveBits(1,ioportType,portName);


            obj.AssignedBits.setBitRangeAssigned(portIdxLSB,portIdxMSB,...
            portName,ioportType,obj.IOStandard,obj.InterfaceID);


            bitRangeData={portIdxLSB-1,portIdxMSB-1};
            hTableMap.setBitRangeData(portName,bitRangeData);
        end

    end


    methods

    end


    methods

    end

end




