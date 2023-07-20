

classdef BlockPortsSingleDimConstraint<slci.compatibility.Constraint

    methods(Access=private)



        function out=isScalarOrVector(aObj,dims)%#ok
            out=false;
            if(numel(dims(dims~=1))==0||...
                numel(dims(dims~=1))==1)
                out=true;
            end
        end
    end

    methods

        function out=getDescription(aObj)
            out=['The inports and outports of '...
            ,aObj.ParentBlock().getName()...
            ,' must be scalars or vectors'];
        end

        function obj=BlockPortsSingleDimConstraint()
            obj.setEnum('BlockPortsSingleDim');
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
                    dims=get_param(portHandles.Inport(i),'CompiledPortDimensions');
                    inFramed=compiledPortFramedSignals.Inport(i);
                    if~inFramed


                        if dims(1)>1
                            if~(aObj.isScalarOrVector(dims(2:end)))
                                out=slci.compatibility.Incompatibility(...
                                aObj,...
                                'SingleDimBlockInport',...
                                num2str(i),...
                                aObj.ParentBlock().getName());
                                return
                            end
                        end
                    end
                end
            end
            if numOut==numel(portHandles.Outport)
                for i=1:numOut
                    dims=get_param(portHandles.Outport(i),'CompiledPortDimensions');
                    inFramed=compiledPortFramedSignals.Outport(i);
                    if~inFramed


                        if dims(1)>1
                            if~(aObj.isScalarOrVector(dims(2:end)))
                                out=slci.compatibility.Incompatibility(...
                                aObj,...
                                'SingleDimBlockInport',...
                                num2str(i),...
                                aObj.ParentBlock().getName());
                                return
                            end
                        end
                    end
                end
            end
        end

    end
end

