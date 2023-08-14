


classdef LookupndFractionDataTypeConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'LookupndFractionDataType',...
            aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=LookupndFractionDataTypeConstraint()
            obj.setEnum('LookupndFractionDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            fractionDataTypeStr=aObj.ParentBlock().getParam('FractionDataTypeStr');
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if~strcmpi(fractionDataTypeStr,'double')&&...
                ~strcmpi(fractionDataTypeStr,'single')&&...
                ~(strcmpi(fractionDataTypeStr,'Inherit: Inherit via internal rule')&&...
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
                aObj.ParentBlock().getUDDObject.FractionDataTypeStr='double';
                out=true;
            catch
            end
        end

    end
end


