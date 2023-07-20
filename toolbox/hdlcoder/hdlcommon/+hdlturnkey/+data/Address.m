


classdef Address<handle


    properties


        AddressStart=0;
        AddressLength=0;
        AddressEnd=0;


        NeedStrobe=false;
        AddressStrobe=0;


        AddressType=hdlturnkey.data.AddrType.UNKNOWN;


        Assigned=false;


        AssignedPortName='';
        AssignedPortType=hdlturnkey.IOType.IN;


        FlattenedPortName='';


        DispFlattenedPortName='';


        DescName='';
        Description='';


        DispDataType='';


        DataType=[];


        InitValue=0;


        FlattenedInitValueName='';


        NeedBitPacking=false
        PortVectorSize=0;
        PortWordLength=0;
        PackedVectorSize=0;
        PackedWordLength=0;


        RequestStrobePort=false;

        AsssignedStrobePortName='';


        AddrBlockSize=0;


        UseShiftRegister=false;


        AddrDecoderPipeline=false;


        ElabScheduled=false;
        ElabInternalSignal={};
        ElabDecoderType=hdlturnkey.data.DecoderType.UNKNOWN;
        ElabStrobeSignal={};


        PortlevelRegisterReadback='inherit';

    end

    methods

        function obj=Address(addrStart,addrLength,addrEnd,needStrobe,addrStrobe)

            obj.AddressStart=addrStart;
            obj.AddressLength=addrLength;
            obj.AddressEnd=addrEnd;
            obj.NeedStrobe=needStrobe;
            obj.AddressStrobe=addrStrobe;
        end

        function cleanScheduledElab(obj)
            obj.ElabScheduled=false;
            obj.ElabInternalSignal=[];
            obj.ElabDecoderType=hdlturnkey.data.DecoderType.UNKNOWN;
        end

        function assignScheduledElab(obj,internalSignal,decoderType)




            obj.ElabScheduled=true;

            if~iscell(internalSignal)
                internalSignal={internalSignal};
            end
            obj.ElabInternalSignal=internalSignal;
            obj.ElabDecoderType=decoderType;
        end

        function assignStrobeSignal(obj,strobeSignal)

            obj.ElabStrobeSignal=strobeSignal;
        end

        function hSignal=addPirSignal(obj,hN,sigName)



            hInternalSignals=obj.ElabInternalSignal;

            dimLen=length(hInternalSignals);
            baseType=hInternalSignals{1}.Type;
            if dimLen==1
                outportType=baseType;
            else
                outportType=pirelab.getPirVectorType(baseType,dimLen);
            end

            hSignal=hN.addSignal(outportType,sigName);
        end

        function isa=isDUTAddress(obj)

            isa=obj.AddressType==hdlturnkey.data.AddrType.USER;
        end

        function name=getDispFlattenedPortNameWithoutPortName(obj)







            name=extractAfter(obj.DispFlattenedPortName,[obj.AssignedPortName,'.']);
        end
    end

    methods(Static)

        function addrInternal=convertAddrExternalToInternal(addrExternal)


            addrInternal=hdlshared.internal.VectorAddressUtils.convertDecimalToInternalAddr(addrExternal);
        end

        function addrExternal=convertAddrInternalToExternal(addrInternal)


            addrExternal=hdlshared.internal.VectorAddressUtils.convertInternalToDecimalAddr(addrInternal);
        end

        function[addrInternal,addrValue]=convertAddrStrToInternal(addrStr)

            addrCell=regexp(addrStr,'x"(\w+)"','tokens','once');
            addrNumStr=addrCell{1};
            addrValue=hex2dec(addrNumStr);
            addrInternal=hdlturnkey.data.Address.convertAddrExternalToInternal(addrValue);
        end

        function addrStr=convertAddrInternalToStr(addrInternal)


            addrExternal=hdlturnkey.data.Address.convertAddrInternalToExternal(addrInternal);
            if length(addrExternal)>1

                addrExternal=min(addrExternal);
            end
            addrStr=sprintf('x"%s"',dec2hex(addrExternal));
        end

        function addrStr=convertAddrInternalToModelGenStr(addrInternal)


            addrExternal=hdlturnkey.data.Address.convertAddrInternalToExternal(addrInternal);
            addrStr=sprintf('hex2dec(''%s'')',dec2hex(addrExternal));
        end

        function addrStr=convertAddrInternalToDecimalStr(addrInternal)


            addrExternal=hdlturnkey.data.Address.convertAddrInternalToExternal(addrInternal);
            addrStr=sprintf('%d',addrExternal);
        end

        function addrStr=convertAddrInternalToCStr(addrInternal)


            addrExternal=hdlturnkey.data.Address.convertAddrInternalToExternal(addrInternal);
            addrStr=sprintf('0x%s',dec2hex(addrExternal));
        end

        function addrDecStr=convertAddrCStrToDec(addrCStr)

            addrDecStr=sprintf('hex2dec(''%s'')',strrep(addrCStr,'0x',''));
        end

    end

end

