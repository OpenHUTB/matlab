



classdef SupportedStateDataTypesConstraint<slci.compatibility.SupportedDataTypesConstraint

    methods
        function obj=SupportedStateDataTypesConstraint(aSupportedTypes)
            obj.setEnum('SupportedStateDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(0);
            obj.setSupportedTypes(aSupportedTypes);
        end

        function out=check(aObj)
            out=[];

            rtObj=aObj.ParentBlock().getParam('RunTimeObject');
            nDworks=rtObj.NumDworks;
            for i=1:nDworks
                rd=rtObj.Dwork(i);
                dataType=rd.Datatype;
                dataWidth=rd.Dimensions;
                if~aObj.supportedType(dataType,dataWidth)
                    out=aObj.getIncompatibility();
                    return
                end
            end
        end
    end
end

