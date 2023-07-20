


classdef LookupndIntermediateResultsDataTypeConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'LookupndIntermediateResultsDataType',...
            aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=LookupndIntermediateResultsDataTypeConstraint()
            obj.setEnum('LookupndIntermediateResultsDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            paramDataTypeStr=aObj.ParentBlock().getParam('IntermediateResultsDataTypeStr');
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if~strcmpi(paramDataTypeStr,'Inherit: Same as output')&&...
                ~strcmpi(paramDataTypeStr,compiledPortDataTypes.Outport{1})
                out=aObj.getIncompatibility();
            end
        end
    end
end


