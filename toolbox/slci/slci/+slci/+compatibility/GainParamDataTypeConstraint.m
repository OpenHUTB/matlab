


classdef GainParamDataTypeConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'GainParamDataType',...
            aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=GainParamDataTypeConstraint()
            obj.setEnum('GainParamDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            paramDataTypeStr=aObj.ParentBlock().getParam('ParamDataTypeStr');
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if~strcmpi(paramDataTypeStr,'Inherit: Same as input')&&...
                ~strcmpi(paramDataTypeStr,compiledPortDataTypes.Inport{1})&&...
                ~(strcmpi(paramDataTypeStr,'Inherit: Inherit via internal rule')&&...
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
                aObj.ParentBlock().getUDDObject.ParamDataTypeStr='Inherit: Same as input';
                out=true;
            catch
            end
        end


    end
end
