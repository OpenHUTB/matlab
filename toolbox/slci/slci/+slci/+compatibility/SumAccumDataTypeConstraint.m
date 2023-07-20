


classdef SumAccumDataTypeConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'SumAccumDataType',...
            aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=SumAccumDataTypeConstraint()
            obj.setEnum('SumAccumDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            accumDataTypeStr=aObj.ParentBlock().getParam('AccumDataTypeStr');
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if~strcmpi(accumDataTypeStr,'Inherit: Same as first input')&&...
                ~strcmpi(accumDataTypeStr,compiledPortDataTypes.Inport{1})&&...
                ~(strcmpi(accumDataTypeStr,'Inherit: Inherit via internal rule')&&...
                (strcmpi('single',compiledPortDataTypes.Inport{1})||...
                strcmpi('double',compiledPortDataTypes.Inport{1})))
                out=aObj.getIncompatibility();
            end
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            try
                aObj.ParentBlock().getUDDObject.AccumDataTypeStr='Inherit: Same as first input';
                out=true;
            catch
            end
        end

    end
end
