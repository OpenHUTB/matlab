


classdef UniformInputPortDataTypesConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'NonUniformInputPortDataTypes',...
            aObj.ParentBlock().getName());
        end

    end

    methods

        function obj=UniformInputPortDataTypesConstraint()
            obj.setEnum('UniformInputPortDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if isempty(compiledPortDataTypes)
                numIn=0;
            else
                numIn=numel(compiledPortDataTypes.Inport);
            end
            if numIn>1
                signalDataType=compiledPortDataTypes.Inport(1);
                for i=1:numIn
                    if~strcmpi(compiledPortDataTypes.Inport{i},signalDataType)
                        out=aObj.getIncompatibility();
                        return
                    end
                end
            end
        end

    end
end
