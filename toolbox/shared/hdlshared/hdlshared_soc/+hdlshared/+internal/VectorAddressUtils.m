classdef VectorAddressUtils<handle











    methods(Static=true)





        function addrBlockSize=getAddrBlockSize(packedAddressLength)

            if packedAddressLength==1
                addrBlockSize=1;
            else
                addrBlockSize=2^ceil(log2(double(packedAddressLength)));
            end

        end








        function[packedAddrLength,packedDataWidth,usePacking]=...
            getPackingParams(vectorLength,...
            vectorElementWidth,...
            registerWidth,...
            bitPacking,...
            bytePacking)

            if nargin<5
                bytePacking=false;
            end
            if nargin<4
                bitPacking=false;
            end
            if nargin<3
                registerWidth=32;
            end
            if nargin<2
                error('must specify vectorLength and vectorElementWidth');
            end


            if(~bitPacking||vectorLength==1)&&~bytePacking
                packedAddrLength=ceil(double(vectorElementWidth)/double(registerWidth))*vectorLength;
                usePacking=false;
                packedDataWidth=registerWidth;
                return;
            end


            if bitPacking&&~bytePacking


                packNumber=max(1,floor(double(registerWidth)/double(vectorElementWidth)));
                usePacking=packNumber>1;

                addrLength=ceil(double(vectorElementWidth)/double(registerWidth))*vectorLength;

                packedAddrLength=ceil(double(addrLength)/double(packNumber));


                packedDataWidth=min(registerWidth,vectorElementWidth*packNumber);
                return;
            end

            error('The options specified are not yet supported');
        end






        function addrStrobe=getStrobeAddr(addrStart,packedAddrLength)

            if packedAddrLength==1
                addrStrobe=0;
            else
                addrBlockSize=hdlshared.internal.VectorAddressUtils.getAddrBlockSize(packedAddrLength);
                hdlshared.internal.VectorAddressUtils.validateStartAddrForBlock(addrStart,addrBlockSize);
                addrStrobe=addrStart+addrBlockSize;
            end
        end




        function blockStartAddr=getNextBlockStartAddr(currentAddr,blockSize)

            if blockSize==1
                blockStartAddr=currentAddr;
            else
                blockStartAddr=ceil(double(currentAddr)/double(blockSize))*blockSize;
            end

        end


    end




    methods(Static=true)


        function validateStartAddrForBlock(addrStart,blockSize)

            blockStartAddr=hdlshared.internal.VectorAddressUtils.getNextBlockStartAddr(addrStart,blockSize);
            if blockStartAddr~=addrStart
                error(message('hdlcommon:workflow:VectorBlockAddress',...
                hdlturnkey.data.Address.convertAddrInternalToStr(blockStartAddr)));
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

