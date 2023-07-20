


classdef IOBitList<handle


    properties

        IOBitMap=[];

        ArrayLength=0;

    end

    methods

        function obj=IOBitList(numBits)


            obj.IOBitMap=containers.Map('KeyType','double','ValueType','any');
            for ii=1:numBits
                obj.IOBitMap(ii)=hdlturnkey.data.IOBit(ii);
            end
            obj.ArrayLength=numBits;

        end


        function hIOBit=getIOBit(obj,bitIdx)

            hIOBit=obj.IOBitMap(bitIdx);
        end

        function cleanAssignment(obj)

            for ii=1:obj.IOBitMap.length
                hIOBit=obj.getIOBit(ii);
                hIOBit.Assigned=false;
                hIOBit.AssignedPortName='';
                hIOBit.AssignedPortType=[];
                hIOBit.AssignedIOStandard='';
                hIOBit.AssignedInterfaceID='';
            end
        end

        function[isAssigned,hViolateIOBit]=isBitRangeAssigned(obj,usrLSB,usrMSB)

            isAssigned=false;
            hViolateIOBit=[];

            for ii=usrLSB:usrMSB
                hIOBit=obj.getIOBit(ii);
                if hIOBit.Assigned
                    isAssigned=true;
                    hViolateIOBit=hIOBit;
                    return;
                end
            end
        end

        function setBitRangeAssigned(obj,usrLSB,usrMSB,portName,portType,ioStandard,interfaceID)


            for ii=usrLSB:usrMSB
                hIOBit=obj.getIOBit(ii);
                hIOBit.Assigned=true;
                hIOBit.AssignedPortName=portName;
                hIOBit.AssignedPortType=portType;
                hIOBit.AssignedIOStandard=ioStandard;
                hIOBit.AssignedInterfaceID=interfaceID;
            end
        end

    end

end

