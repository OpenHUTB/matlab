classdef SpecificationsUtilities






    methods(Static)
        function isNT=isNameOfNumericType(ntStr)













            isNT=false(numel(ntStr,1));
            for nIndex=1:numel(ntStr)
                try
                    fixed.internal.type.extractNumericType(ntStr{nIndex});
                catch
                    continue;

                end
                isNT(nIndex)=true;
            end
        end

        function dtAreEq=areEquivalentDataTypes(dt1,dt2)





            parsedDT1=parseDataType(dt1);
            parsedDT2=parseDataType(dt2);
            dtAreEq=fixed.internal.type.areEquivalent(parsedDT1.ResolvedString,parsedDT2.ResolvedString);

        end
    end
end




