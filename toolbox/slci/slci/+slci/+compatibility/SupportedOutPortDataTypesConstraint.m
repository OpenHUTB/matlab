


classdef SupportedOutPortDataTypesConstraint<slci.compatibility.SupportedPortDataTypesConstraint

    methods

        function obj=SupportedOutPortDataTypesConstraint(aSupportedTypes)
            obj=obj@slci.compatibility.SupportedPortDataTypesConstraint(aSupportedTypes);
            obj.setSupportedTypes(aSupportedTypes);
            obj.setEnum('SupportedOutPortDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(0);
        end

        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            compiledPortWidths=aObj.ParentBlock().getParam('CompiledPortWidths');
            if isempty(compiledPortDataTypes)
                numOut=0;
            else
                numOut=numel(compiledPortDataTypes.Outport);
            end
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            if numOut==numel(portHandles.Outport)
                for i=1:numOut
                    outDataType=compiledPortDataTypes.Outport{i};
                    outWidth=compiledPortWidths.Outport(i);
                    if~aObj.supportedType(outDataType,outWidth)
                        out=aObj.getIncompatibility();
                        return
                    end
                end
            end
        end
    end
end
