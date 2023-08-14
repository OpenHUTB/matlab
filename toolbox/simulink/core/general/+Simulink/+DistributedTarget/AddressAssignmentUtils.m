





classdef AddressAssignmentUtils<handle
    methods(Static=true)




        function[startAddr,endAddr]=getSignalAddress(currentAddr,...
            portVectorSize,portDataType)
            switch portDataType
            case{'uint8','int8'}
                portWordLength=8;
            case{'uint16','int16'}
                portWordLength=16;
            case{'uint32','int32'}
                portWordLength=32;
            otherwise
                assert(false,'Not yet supported');
            end


            addrLength=...
            Simulink.DistributedTarget.AddressAssignmentUtils.getBitPackingParams(...
            portVectorSize,portWordLength);


            blockSize=...
            Simulink.DistributedTarget.AddressAssignmentUtils.getAddressBlockSize(...
            addrLength);


            internalAddr=...
            Simulink.DistributedTarget.AddressAssignmentUtils.convertDecimalToInternalAddr(...
            currentAddr);


            startInternalAddr=...
            Simulink.DistributedTarget.AddressAssignmentUtils.getNextAddressBlockStartAddr(...
            internalAddr,blockSize);


            endInternalAddr=...
            Simulink.DistributedTarget.AddressAssignmentUtils.calculateAddressEnd(...
            startInternalAddr,addrLength,blockSize);


            startAddr=...
            Simulink.DistributedTarget.AddressAssignmentUtils.convertInternalToDecimalAddr(...
            startInternalAddr);


            endAddr=...
            Simulink.DistributedTarget.AddressAssignmentUtils.convertInternalToDecimalAddr(...
            endInternalAddr);
        end




        function addrStrobe=getStrobeAddress(startAddr,portVectorSize,...
            portDataType)
            switch portDataType
            case{'uint8','int8'}
                portWordLength=8;
            case{'uint16','int16'}
                portWordLength=16;
            case{'uint32','int32'}
                portWordLength=32;
            otherwise
                assert(false,'Not yet supported');
            end

            addrLength=...
            Simulink.DistributedTarget.AddressAssignmentUtils.getBitPackingParams(...
            portVectorSize,portWordLength);

            if addrLength==1
                addrStrobe=0;
            else

                blockSize=...
                Simulink.DistributedTarget.AddressAssignmentUtils.getAddressBlockSize(...
                addrLength);
                startAddrInternal=...
                Simulink.DistributedTarget.AddressAssignmentUtils.convertDecimalToInternalAddr(...
                startAddr);
                addrEnd=startAddrInternal+blockSize;
                addrStrobe=...
                Simulink.DistributedTarget.AddressAssignmentUtils.convertInternalToDecimalAddr(...
                addrEnd);
            end
        end






        function blockSize=getAddressBlockSize(addrLength)

            if addrLength==1
                blockSize=1;
            else
                blockSize=2^ceil(log2(double(addrLength)));
            end
        end



        function blockStartAddr=getNextAddressBlockStartAddr(currentAddr,...
            blockSize)

            if blockSize==1
                blockStartAddr=currentAddr;
            else
                blockStartAddr=...
                ceil(double(currentAddr)/double(blockSize))*blockSize;
            end
        end




        function packedVectorSize=getBitPackingParams(portVectorSize,portWordLength)

            if portVectorSize>1

                packNumber=floor(32.0/double(portWordLength));

                packedVectorSize=ceil(double(portVectorSize)/double(packNumber));
            else

                packedVectorSize=portVectorSize;
            end
        end


        function addrEnd=calculateAddressEnd(addrStart,addrLength,blockSize)
            if addrLength==1

                addrEnd=addrStart;
            else


                addrEnd=addrStart+blockSize;
            end
        end


        function addrInternal=convertDecimalToInternalAddr(decimalAddr)
            addrInternalFi=bitsliceget(fi(decimalAddr,0,20,0),20,3);
            addrInternal=addrInternalFi.data;
        end


        function decimalAddr=convertInternalToDecimalAddr(addrInternal)
            decimalAddrFi=bitconcat(fi(addrInternal,0,18,0),fi(0,0,2,0));
            decimalAddr=decimalAddrFi.data;
        end
    end
end


