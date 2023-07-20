





classdef HWDeviceRegistry<RTW.RegistryObject





























    properties(AbortSet,SetObservable,GetObservable)

        Vendor='';

        Type='';

        Alias={};

        Platform={'Prod','Target'};

        BitPerChar=8;

        BitPerShort=16;

        BitPerInt=32;

        BitPerLong=32;

        BitPerLongLong=64;

        WordSize=32;

        Endianess='Unspecified';

        IntDivRoundTo='Undefined';

        LargestAtomicInteger='Char';

        LargestAtomicFloat='None';

        ShiftRightIntArith=false;

        LongLongMode=false;

        BitPerFloat=32;

        BitPerDouble=64;

        BitPerPointer=32;

        BitPerSizeT=32;

        BitPerPtrDiffT=32;

        Grandfathered=false;
    end

    properties(SetAccess=protected,AbortSet,SetObservable,GetObservable)

        Visible=[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true];

        Enabled=[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false];
    end


    methods
        function h=HWDeviceRegistry(varargin)

























            mlock;

            msg=message('RTW:targetRegistry:ClassToBeRemoved');
            if h.throwDeprecationError()
                error(msg);
            else
                warning(msg);
            end



        end

    end

    methods(Static,Hidden)
        function loadedH=loadobj(~)%#ok<STOUT>
            error(message('RTW:targetRegistry:ClassToBeRemoved'))
        end

        out=throwDeprecationError(in)
    end

    methods(Static)
        function h=fromStruct(hwStruct)
            h=RTW.HWDeviceRegistry;%#ok<RTWHWDR>
            h.Vendor=hwStruct.Vendor;
            h.Type=hwStruct.Type;
            h.Alias=hwStruct.Alias;
            h.Platform=hwStruct.Platform;
            h.BitPerChar=hwStruct.BitPerChar;
            h.BitPerShort=hwStruct.BitPerShort;
            h.BitPerInt=hwStruct.BitPerInt;
            h.BitPerLong=hwStruct.BitPerLong;
            h.BitPerLongLong=hwStruct.BitPerLongLong;
            h.WordSize=hwStruct.WordSize;
            h.Endianess=hwStruct.Endianess;
            h.IntDivRoundTo=hwStruct.IntDivRoundTo;
            h.LargestAtomicInteger=hwStruct.LargestAtomicInteger;
            h.LargestAtomicFloat=hwStruct.LargestAtomicFloat;
            h.ShiftRightIntArith=hwStruct.ShiftRightIntArith;
            h.LongLongMode=hwStruct.LongLongMode;
            h.BitPerFloat=hwStruct.BitPerFloat;
            h.BitPerDouble=hwStruct.BitPerDouble;
            h.BitPerPointer=hwStruct.BitPerPointer;
            h.BitPerSizeT=hwStruct.BitPerSizeT;
            h.BitPerPtrDiffT=hwStruct.BitPerPtrDiffT;
            h.Grandfathered=hwStruct.Grandfathered;
            h.Enabled=hwStruct.Enabled;
            h.Visible=hwStruct.Visible;
        end
    end

    methods
        function set.Vendor(obj,value)

            validateattributes(value,{'char'},{'row'},'','Vendor')
            obj.Vendor=value;
        end

        function set.Type(obj,value)

            validateattributes(value,{'char'},{'row'},'','Type')
            obj.Type=value;
        end

        function set.Alias(obj,value)


            value=reshape(value,length(value),1);
            obj.Alias=value;
        end

        function set.Platform(obj,value)


            value=reshape(value,length(value),1);
            obj.Platform=value;
        end

        function set.BitPerChar(obj,value)

            validateattributes(value,{'double'},{'scalar'},'','BitPerChar')
            obj.BitPerChar=value;
        end

        function set.BitPerShort(obj,value)

            validateattributes(value,{'double'},{'scalar'},'','BitPerShort')
            obj.BitPerShort=value;
        end

        function set.BitPerInt(obj,value)

            validateattributes(value,{'double'},{'scalar'},'','BitPerInt')
            obj.BitPerInt=value;
        end

        function set.BitPerLong(obj,value)

            validateattributes(value,{'double'},{'scalar'},'','BitPerLong')
            obj.BitPerLong=value;
        end

        function set.BitPerLongLong(obj,value)

            validateattributes(value,{'double'},{'scalar'},'','BitPerLongLong')
            obj.BitPerLongLong=value;
        end

        function set.LongLongMode(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','LongLongMode')
            obj.LongLongMode=value;
        end

        function set.WordSize(obj,value)

            validateattributes(value,{'double'},{'scalar'},'','WordSize')
            obj.WordSize=value;
        end

        function set.Endianess(obj,value)

            value=validatestring(value,{'BigEndian','LittleEndian','Unspecified'},'','Endianess');
            obj.Endianess=value;
        end

        function set.IntDivRoundTo(obj,value)

            value=validatestring(value,{'Floor','Zero','Undefined'},'','IntDivRoundTo');
            obj.IntDivRoundTo=value;
        end

        function set.LargestAtomicInteger(obj,value)

            value=validatestring(value,{'Char','Short','Int','Long','LongLong'},'','LargestAtomicInteger');
            obj.LargestAtomicInteger=value;
        end

        function set.LargestAtomicFloat(obj,value)

            value=validatestring(value,{'Float','Double','None'},'','LargestAtomicFloat');
            obj.LargestAtomicFloat=value;
        end

        function set.ShiftRightIntArith(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','ShiftRightIntArith')
            obj.ShiftRightIntArith=value;
        end

        function set.BitPerFloat(obj,value)

            validateattributes(value,{'double'},{'scalar'},'','BitPerFloat')
            obj.BitPerFloat=value;
        end

        function set.BitPerDouble(obj,value)

            validateattributes(value,{'double'},{'scalar'},'','BitPerDouble')
            obj.BitPerDouble=value;
        end

        function set.BitPerPointer(obj,value)

            validateattributes(value,{'double'},{'scalar'},'','BitPerPointer')
            obj.BitPerPointer=value;
        end

        function set.Visible(obj,value)
            obj.Visible=value;
        end

        function set.Enabled(obj,value)
            obj.Enabled=value;
        end

    end

    methods(Hidden)
        setDisabled(h,fields)
        isEnabled=getEnabled(h,field)
        setEnabled(h,fields)
        setInvisible(h,fields)
        setVisible(h,fields)
        setWordSizes(h,ws)
        s=toStruct(h)
        params=getEnabledParams(h)
    end

    methods(Hidden)


        function value=calculateHWDeviceTypeValue(h)
            value=[h.Vendor,'->',h.Type];
        end
    end

end





