

classdef SignalDatatypeConstraint<slci.compatibility.Constraint




    methods

        function out=getDescription(aObj)%#ok
            out=['A blocks compiled outport datatype must match its'...
            ,' destination port compiled datatype.'];
        end


        function obj=SignalDatatypeConstraint()
            obj.setEnum('SignalDatatype');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];



            ports=aObj.ParentBlock().getParam('Porthandles');
            outports=ports.Outport;

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            for pH=1:numel(outports)
                portDataType=get_param(outports(pH),...
                'CompiledPortDataType');
                portObj=get_param(outports(pH),'Object');
                dstPorts=portObj.getActualDst();
                numDsts=size(dstPorts,1);

                for iDst=1:numDsts
                    dstPortH=dstPorts(iDst,1);
                    dstPortDataType=get_param(dstPortH,...
                    'CompiledPortDataType');
                    if(dstPortDataType~=portDataType)
                        out=slci.compatibility.Incompatibility(aObj,...
                        'SignalDatatype',...
                        aObj.ParentBlock.getName());
                        return;
                    end
                end
            end
            delete(sess);

        end

    end
end
