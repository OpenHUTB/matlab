


classdef BlockPortsNonFramedConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)
            out=['The inports and outports of '...
            ,aObj.ParentBlock().getName()...
            ,' must be non-framed'];
        end

        function obj=BlockPortsNonFramedConstraint()
            obj.setEnum('BlockPortsNonFramed');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            compiledPortFramedSignals=aObj.ParentBlock().getParam('CompiledPortFrameData');
            if isempty(compiledPortFramedSignals)
                numIn=0;
                numOut=0;
            else
                numIn=numel(compiledPortFramedSignals.Inport);
                numOut=numel(compiledPortFramedSignals.Outport);
            end
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            if numIn==numel(portHandles.Inport)
                for i=1:numIn
                    inFramed=compiledPortFramedSignals.Inport(i);
                    if inFramed
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'FramedBlockInport',...
                        num2str(i),...
                        aObj.ParentBlock().getName());
                        return
                    end
                end
            end
            if numOut==numel(portHandles.Outport)
                for i=1:numOut
                    outFramed=compiledPortFramedSignals.Outport(i);
                    if outFramed
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'FramedBlockOutport',...
                        num2str(i),...
                        aObj.ParentBlock().getName());
                        return
                    end
                end
            end
        end

    end
end

