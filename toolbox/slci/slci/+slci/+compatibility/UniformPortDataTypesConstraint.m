


classdef UniformPortDataTypesConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'NonUniformPortDataTypes',...
            aObj.ParentBlock().getName());
        end

    end

    methods

        function obj=UniformPortDataTypesConstraint()
            obj.setEnum('UniformPortDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if isempty(compiledPortDataTypes)
                numIn=0;
                numOut=0;
            else
                numIn=numel(compiledPortDataTypes.Inport);
                numOut=numel(compiledPortDataTypes.Outport);
            end
            if numIn>0
                signalDataType=compiledPortDataTypes.Inport(1);
            elseif numOut>0
                signalDataType=compiledPortDataTypes.Outport(1);
            end
            for i=1:numIn
                if~strcmpi(compiledPortDataTypes.Inport{i},signalDataType)
                    out=aObj.getIncompatibility();
                    return
                end
            end
            for i=1:numOut
                if~strcmpi(compiledPortDataTypes.Outport{i},signalDataType)
                    out=aObj.getIncompatibility();
                    return
                end
            end
        end

    end
end
