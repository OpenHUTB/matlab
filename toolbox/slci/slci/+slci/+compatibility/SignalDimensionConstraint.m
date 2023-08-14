

classdef SignalDimensionConstraint<slci.compatibility.Constraint




    methods

        function out=getDescription(aObj)%#ok
            out=['A blocks compiled outport dimension must match its'...
            ,' destination port compiled dimension.'];
        end


        function obj=SignalDimensionConstraint()
            obj.setEnum('SignalDimension');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];



            ports=aObj.ParentBlock().getParam('Porthandles');
            outports=ports.Outport;

            for pH=1:numel(outports)
                portDim=get_param(outports(pH),...
                'CompiledPortDimensions');
                sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
                portObj=get_param(outports(pH),'Object');
                dstPorts=portObj.getGraphicalDst();
                numDsts=size(dstPorts,1);

                for iDst=1:numDsts
                    dstPortH=dstPorts(iDst,1);
                    dstPortDim=get_param(dstPortH,...
                    'CompiledPortDimensions');
                    if~all(dstPortDim==portDim)
                        out=slci.compatibility.Incompatibility(aObj,...
                        'SignalDimension',...
                        aObj.ParentBlock.getName());
                        return;
                    end
                end
                delete(sess);
            end

        end

    end
end
