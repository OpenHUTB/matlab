classdef Builder16<coder.internal.asap2.Builder15









    methods(Access=public)


        function[conversionType,coeffs]=getCoeffsAndConversTypeOfCompuMethod(~,slope,bias)
            conversionType='LINEAR';
            if(slope==1)&&(bias==0)
                conversionType='IDENTICAL';
                coeffs=[];
            elseif slope<0
                coeffs=[-slope,bias];
            else
                coeffs=[slope,bias];
            end
        end



        function isSupported=isLookupDimensionsSupported(~,~)
            isSupported=true;
        end


        function isSupported=isSupportedDataType(this,dataType)
            isSupported=true;
            if isa(dataType,'coder.descriptor.types.Half')...
                ||isa(dataType,'coder.descriptor.types.Char')...
                ||isa(dataType,'coder.descriptor.types.Opaque')

                isSupported=false;

            elseif isa(dataType,'coder.descriptor.types.Fixed')
                if dataType.WordLength>64||...
                    dataType.WordLength==64&&~this.Data.Support64bitIntegers
                    isSupported=false;
                end
            elseif isa(dataType,'coder.descriptor.types.Complex')

                isSupported=false;
            end
        end
    end
end


