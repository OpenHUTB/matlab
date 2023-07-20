



classdef MatlabFunctionNegativeParameterConstraint<slci.compatibility.MatlabFunctionParameterConstraint



    methods


        function obj=MatlabFunctionNegativeParameterConstraint(aFatal,...
            aParameterName,...
            aParameterValue,...
            aDispParameterName,...
aDispParameterValue...
            )

            obj@slci.compatibility.MatlabFunctionParameterConstraint(aFatal,...
            aParameterName,...
            aParameterValue,...
            aDispParameterName,...
aDispParameterValue...
            );
            obj.setEnum('MatlabFunctionNegativeParameter');
        end


        function out=check(aObj)
            out=[];
            parameterName=aObj.fParameterName;
            chartUDD=aObj.ParentChart().getUDDObject();
            parameterValue=chartUDD.(parameterName);
            unsupportedValues=aObj.fParameterValues;
            for idx=1:numel(unsupportedValues)
                if isequal(parameterValue,unsupportedValues{idx})
                    out=aObj.getIncompatibility();
                    return
                end
            end
        end

    end
end
