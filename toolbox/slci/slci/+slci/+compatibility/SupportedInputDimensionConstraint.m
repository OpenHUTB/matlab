






classdef SupportedInputDimensionConstraint<slci.compatibility.Constraint

    methods


        function obj=SupportedInputDimensionConstraint()
            obj.setEnum('SupportedInputDimension');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=getDescription(aObj)%#ok
            out='The Dimension of the input must be less than the value of the "Buffer size of dynamically-sized string (bytes)"';
        end


        function out=check(aObj)
            out=[];
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            blk_type=aObj.ParentBlock().getParam('BlockType');
            assert(strcmpi(blk_type,'ASCIIToString'));
            inWidth=get_param(portHandles.Inport(),'CompiledPortWidth');
            dynamicStringBufferSize=aObj.ParentModel().getParam('DynamicStringBufferSize');
            if inWidth>=dynamicStringBufferSize
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SupportedInputDimension',...
                aObj.ParentBlock().getName());
            end
        end

    end

end
