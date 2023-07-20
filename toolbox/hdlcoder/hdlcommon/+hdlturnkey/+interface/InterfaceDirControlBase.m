


classdef InterfaceDirControlBase<hdlturnkey.interface.InterfaceIOBase




    properties


    end

    methods

        function obj=InterfaceDirControlBase(interfaceID,interfaceType,portWidth,channelWidth,sharedAssignment)


            if nargin<5
                sharedAssignment=[];
            end

            if nargin<4
                channelWidth=portWidth;
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
            portIdxLSB=bitRangeData{1}+1;
            portIdxMSB=bitRangeData{2}+1;


            [isAssigned,hViolateIOBit]=obj.AssignedBits.isBitRangeAssigned(portIdxLSB,portIdxMSB);
            if isAssigned

                error(message('hdlcommon:workflow:DupSpec',hViolateIOBit.BitIndex-1,portName,hViolateIOBit.AssignedPortName));
            end


            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            ioportType=hIOPort.PortType;





            adjacentIdxLSB=portIdxLSB-1;
            adjacentIdxMSB=portIdxMSB+1;
            if adjacentIdxLSB>0&&mod(adjacentIdxLSB,2)==1
                obj.checkDirControlLimitation(adjacentIdxLSB,ioportType,portIdxLSB,portName);
            end
            if adjacentIdxMSB<=obj.PortWidth&&mod(adjacentIdxMSB,2)==0
                obj.checkDirControlLimitation(adjacentIdxMSB,ioportType,portIdxMSB,portName);
            end


            obj.AssignedBits.setBitRangeAssigned(portIdxLSB,portIdxMSB,...
            portName,ioportType,obj.IOStandard,obj.InterfaceID);
        end

        function checkDirControlLimitation(obj,adjacentIdx,portType,portIdx,portName)
            hIOBitAdj=obj.AssignedBits.getIOBit(adjacentIdx);
            if hIOBitAdj.Assigned&&hIOBitAdj.AssignedPortType~=portType
                error(message('hdlcommon:workflow:DirControlLimitation',portIdx-1,portName,adjacentIdx-1,portIdx-1));
            end
        end

        function[portIdxLSB,portIdxMSB]=allocateConsecutiveBits(obj,ioportWidth,ioportType,portName)

            idxStart=1;
            idxEnd=0;
            for ii=1:obj.AssignedBits.ArrayLength
                hIOBit=obj.AssignedBits.getIOBit(ii);
                iobitType=hIOBit.getIOBitType(obj.IOStandard);

                adjacentIdxLSB=ii-1;

                if hIOBit.Assigned

                    idxStart=ii+1;

                elseif iobitType~=hdlturnkey.IOType.INOUT&&iobitType~=ioportType

                    idxStart=ii+1;

                elseif adjacentIdxLSB>0&&mod(adjacentIdxLSB,2)==1&&...
                    obj.AssignedBits.getIOBit(adjacentIdxLSB).Assigned&&...
                    obj.AssignedBits.getIOBit(adjacentIdxLSB).AssignedPortType~=ioportType

                    idxStart=ii+1;

                elseif ii-idxStart+1==ioportWidth

                    adjacentIdxMSB=ii+1;
                    if adjacentIdxMSB<=obj.PortWidth&&mod(adjacentIdxMSB,2)==0&&...
                        obj.AssignedBits.getIOBit(adjacentIdxMSB).Assigned&&...
                        obj.AssignedBits.getIOBit(adjacentIdxMSB).AssignedPortType~=ioportType

                        idxStart=ii+1;
                    else
                        idxEnd=ii;
                        break;
                    end
                end
            end
            if idxEnd==0
                error(message('hdlcommon:workflow:UnableAutoAssign',ioportWidth,obj.InterfaceID,portName));
            end

            portIdxLSB=idxStart;
            portIdxMSB=idxEnd;
        end

    end


    methods

        function dirConstVal=getDirControlConstant(obj)






            dirControlWidth=floor(obj.AssignedBits.ArrayLength/2);
            dirConst=zeros(1,dirControlWidth);

            for ii=1:2:obj.AssignedBits.ArrayLength
                hIOBit=obj.AssignedBits.getIOBit(ii);
                hIOBitNext=obj.AssignedBits.getIOBit(ii+1);

                if~hIOBit.Assigned&&~hIOBitNext.Assigned

                    ioportType=hdlturnkey.IOType.IN;
                elseif hIOBit.Assigned&&~hIOBitNext.Assigned
                    ioportType=hIOBit.AssignedPortType;
                elseif~hIOBit.Assigned&&hIOBitNext.Assigned
                    ioportType=hIOBitNext.AssignedPortType;
                else

                    if hIOBit.AssignedPortType~=hIOBitNext.AssignedPortType
                        error(message('hdlcommon:workflow:DirControlError',ii-1,ii));
                    end
                    ioportType=hIOBit.AssignedPortType;
                end


                dirControlIdx=dirControlWidth-floor((ii+1)/2)+1;
                if ioportType==hdlturnkey.IOType.IN
                    dirConst(dirControlIdx)=0;
                else
                    dirConst(dirControlIdx)=1;
                end
            end

            dirConstVal=bitconcat(fi(dirConst,0,1,0));

        end

    end


    methods

    end


    methods

    end
end

