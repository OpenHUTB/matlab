classdef(Abstract)AmiType<serdes.internal.ibisami.ami.Keyword




    methods(Access=protected)
        function verified=verifyValue(~,value)


            verified=false;
            if~isa(value,'char')&&~isa(value,'string')
                return
            end

            verified=true;
        end
        function isDouble=isAmiDouble(~,value)



            isDouble=false;
            if~isscalar(value)
                return
            end
            if~isa(value,'double')
                return
            end
            if isnan(value)||isinf(value)
                return
            end
            if~imag(value)==0
                return
            end
            isDouble=true;
        end
    end
    methods

    end
    methods(Abstract)


        verificationResult=verifyValueForType(amiType,value)
        isEqual=isEqual(amiType,value1,value2)
        convertedValue=convertStringValueToType(amiType,value)
        amiValue=convertToAmiValue(amiType,value)
    end
    methods

        function branch=getKeyWordBranch(~,types,~)
            branch="(Type";
            for idx=1:length(types)
                type=types{idx};
                branch=branch+" "+type.Name;
            end
            branch=branch+")";
        end
    end
end

