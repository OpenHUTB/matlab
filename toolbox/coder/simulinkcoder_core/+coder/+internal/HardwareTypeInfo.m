classdef HardwareTypeInfo<handle




    properties(SetAccess=immutable)
        CharNumBits(1,1)double
        ShortNumBits(1,1)double
        IntNumBits(1,1)double
        LongNumBits(1,1)double
        LongLongNumBits double{mustBeScalarOrEmpty}=[]
    end

    properties(Dependent)
LongLongMode
    end

    methods


        function val=get.LongLongMode(this)
            val=~isempty(this.LongLongNumBits);
        end


        function sizes=getTypeSizes(this)
            sizes=[this.CharNumBits,this.ShortNumBits,this.IntNumBits...
            ,this.LongNumBits,this.LongLongNumBits];
        end


        function types=getPrimitiveSignedTypes(this)
            types={'signed char','short','int','long'};
            if this.LongLongMode
                types{end+1}='long long';
            end
        end


        function types=getPrimitiveUnsignedTypes(this)
            types={'unsigned char','unsigned short','unsigned int',...
            'unsigned long'};
            if this.LongLongMode
                types{end+1}='unsigned long long';
            end
        end


        function this=HardwareTypeInfo(hardwareInfoStruct)
            this.CharNumBits=hardwareInfoStruct.CharNumBits;
            this.ShortNumBits=hardwareInfoStruct.ShortNumBits;
            this.IntNumBits=hardwareInfoStruct.IntNumBits;
            this.LongNumBits=hardwareInfoStruct.LongNumBits;
            if hardwareInfoStruct.LongLongMode
                this.LongLongNumBits=hardwareInfoStruct.LongLongNumBits;
            end
        end
    end
end
