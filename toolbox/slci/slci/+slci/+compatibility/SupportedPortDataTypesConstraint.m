classdef SupportedPortDataTypesConstraint<slci.compatibility.SupportedDataTypesConstraint



    methods

        function obj=SupportedPortDataTypesConstraint(aSupportedTypes)
            obj.setSupportedTypes(aSupportedTypes);
            obj.setEnum('SupportedPortDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(0);
        end

        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            compiledPortWidths=aObj.ParentBlock().getParam('CompiledPortWidths');
            if isempty(compiledPortDataTypes)
                numIn=0;
                numOut=0;
            else
                numIn=numel(compiledPortDataTypes.Inport);
                numOut=numel(compiledPortDataTypes.Outport);
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