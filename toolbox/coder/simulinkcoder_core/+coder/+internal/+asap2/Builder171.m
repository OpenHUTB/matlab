classdef Builder171<coder.internal.asap2.Builder17









    methods(Access=public)


        function isSupported=isSupportedDataType(this,dataType)
            isSupported=true;

            if isa(dataType,'coder.descriptor.types.Char')
                isSupported=false;
            elseif isa(dataType,'coder.descriptor.types.Fixed')
                if dataType.WordLength>64||...
                    dataType.WordLength==64&&~this.Data.Support64bitIntegers
                    isSupported=false;
                end
            elseif isa(dataType,'coder.descriptor.types.Opaque')
                isSupported=false;
            elseif isa(dataType,'coder.descriptor.types.Complex')

                isSupported=false;
            end
        end

    end
end


