classdef Builder13<coder.internal.asap2.BuilderBase









    methods(Access=public)


        function[conversionType,coeffs]=getCoeffsAndConversTypeOfCompuMethod(~,slope,bias)
            conversionType='RAT_FUNC';
            if(bias==0)&&(slope==1)
                coeffs=[0,1,0,0,0,1];
            elseif slope<1
                coeffs=[0,1/slope,(-bias)/slope,0,0,1];
            else
                coeffs=[0,1,(-bias),0,0,slope];
            end
        end



        function isSupported=isLookupDimensionsSupported(~,size)
            isSupported=size<=3;
        end



        function isSupported=isSupportedDataType(~,dataType,~)
            isSupported=true;
            if(isa(dataType,'coder.descriptor.types.Integer')...
                ||isa(dataType,'coder.descriptor.types.Fixed'))
                if dataType.WordLength>32
                    isSupported=false;
                end
            elseif isa(dataType,'coder.descriptor.types.Half')
                isSupported=false;

            elseif isa(dataType,'coder.descriptor.types.Char')
                isSupported=false;
            elseif isa(dataType,'coder.descriptor.types.Opaque')
                isSupported=false;
            elseif isa(dataType,'coder.descriptor.types.Complex')

                isSupported=false;
            end
        end
        function isSupported=isEcuAddressExtensionSupported(~)

            isSupported=false;
        end
    end
end


