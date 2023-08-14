

classdef BlockPortsCompiledDimensionConstraint<slci.compatibility.Constraint




    methods

        function out=getDescription(aObj)
            out=['The compiled and graphical dimensions of inports, outports, '...
            ,'and enable ports of '...
            ,aObj.ParentBlock().getName()...
            ,' must match'];
        end


        function obj=BlockPortsCompiledDimensionConstraint()
            obj.setEnum('BlockPortsCompiledDimension');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            portHandles=aObj.ParentBlock().getParam('PortHandles');

            blkH=aObj.ParentBlock().getParam('Handle');
            propDataTypes=aObj.ParentModel().getPortDatatype(blkH);


            inports=portHandles.Inport;
            if(~isempty(inports))
                assert(numel(propDataTypes.Inport)==2);
                propDims=propDataTypes.Inport{2};
                for i=1:numel(inports)
                    compiledDT=get_param(inports(i),'CompiledPortDimensions');
                    compiledDT=compiledDT(2:end);
                    propDT=propDims{i};
                    if~all(compiledDT==propDT)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'BlockPortsCompiledDimension',...
                        aObj.ParentBlock().getName());
                        return
                    end
                end
            end


            outports=portHandles.Outport;
            if(~isempty(outports))
                assert(numel(propDataTypes.Outport)==2);
                propDims=propDataTypes.Outport{2};
                for i=1:numel(outports)
                    compiledDT=get_param(outports(i),'CompiledPortDimensions');
                    compiledDT=compiledDT(2:end);
                    propDT=propDims{i};
                    if(any(compiledDT==propDT)==0)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'BlockPortsCompiledDimension',...
                        aObj.ParentBlock().getName());
                        return
                    end
                end
            end


            enablePorts=portHandles.Enable;
            if(~isempty(enablePorts))
                propDims=propDataTypes.Enable{2};
                for i=1:numel(outports)
                    compiledDT=get_param(enablePorts(i),'CompiledPortDimensions');
                    propDT=propDims{i};
                    if~strcmpi(compiledDT,propDT)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'BlockPortsCompiledDimension',...
                        aObj.ParentBlock().getName());
                        return
                    end
                end
            end
        end

    end
end
