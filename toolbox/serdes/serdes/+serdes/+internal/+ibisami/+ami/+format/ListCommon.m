classdef(Abstract)ListCommon<serdes.internal.ibisami.ami.format.AmiFormat




    methods

        function verified=verifyValueForType(format,type,valuePassed)


            verified=false;
            if~isa(type,'serdes.internal.ibisami.ami.type.AmiType')
                return;
            end
            value=string(valuePassed);
            if~type.verifyValueForType(value)
                return
            end
            for testValue=format.Values
                if type.isEqual(testValue,value)
                    verified=true;
                    return
                end
            end
        end
    end
end

