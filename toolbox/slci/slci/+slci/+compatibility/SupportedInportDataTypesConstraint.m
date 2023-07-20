

classdef SupportedInportDataTypesConstraint<slci.compatibility.SupportedPortDataTypesConstraint

    methods

        function obj=SupportedInportDataTypesConstraint(aSupportedTypes)
            obj=obj@slci.compatibility.SupportedPortDataTypesConstraint(aSupportedTypes);
            obj.setSupportedTypes(aSupportedTypes);
            obj.setEnum('SupportedInportDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(0);
        end

        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            compiledPortWidths=aObj.ParentBlock().getParam('CompiledPortWidths');
            if isempty(compiledPortDataTypes)
                numIn=0;
            else
                numIn=numel(compiledPortDataTypes.Inport);
            end
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            if numIn==numel(portHandles.Inport)
                for i=1:numIn
                    inDataType=compiledPortDataTypes.Inport{i};
                    inWidth=compiledPortWidths.Inport(i);
                    if~aObj.supportedType(inDataType,inWidth)
                        out=aObj.getIncompatibility();
                        return
                    end
                end
            end
        end
    end
end
