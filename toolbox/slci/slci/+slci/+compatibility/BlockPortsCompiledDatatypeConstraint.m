

classdef BlockPortsCompiledDatatypeConstraint<slci.compatibility.Constraint




    methods

        function out=getDescription(aObj)
            out=['The compiled and graphical datatypes of inports, outports, '...
            ,'and enable ports of '...
            ,aObj.ParentBlock().getName()...
            ,' must match'];
        end


        function obj=BlockPortsCompiledDatatypeConstraint()
            obj.setEnum('BlockPortsCompiledDatatype');
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
                propTypes=propDataTypes.Inport{1};
                for i=1:numel(inports)
                    compiledDT=get_param(inports(i),'CompiledPortDataType');
                    propDT=propTypes{i};
                    if~strcmpi(compiledDT,propDT)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'BlockPortsCompiledDatatype',...
                        aObj.ParentBlock().getName());
                        return
                    end
                end
            end


            outports=portHandles.Outport;
            if(~isempty(outports))
                propTypes=propDataTypes.Outport{1};
                for i=1:numel(outports)
                    compiledDT=get_param(outports(i),'CompiledPortDataType');
                    propDT=propTypes{i};
                    if~strcmpi(compiledDT,propDT)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'BlockPortsCompiledDatatype',...
                        aObj.ParentBlock().getName());
                        return
                    end
                end
            end


            enablePorts=portHandles.Enable;
            if(~isempty(enablePorts))
                propTypes=propDataTypes.Enable{1};
                for i=1:numel(outports)
                    compiledDT=get_param(enablePorts(i),'CompiledPortDataType');
                    propDT=propTypes{i};
                    if~strcmpi(compiledDT,propDT)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'BlockPortsCompiledDatatype',...
                        aObj.ParentBlock().getName());
                        return
                    end
                end
            end

        end

    end
end

