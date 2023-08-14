


classdef BlockPortsNonComplexConstraint<slci.compatibility.Constraint

    properties(Access=private)


        complexityTable=[];

    end


    methods

        function out=getDescription(aObj)
            out=['The inports and outports of '...
            ,aObj.ParentBlock().getName()...
            ,' must be non-complex'];
        end

        function obj=BlockPortsNonComplexConstraint()
            obj.setEnum('BlockPortsNonComplex');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
            obj.complexityTable=containers.Map;
        end

        function out=check(aObj)
            out=[];
            compiledPortComplexSignals=aObj.ParentBlock().getParam('CompiledPortComplexSignals');
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if isempty(compiledPortComplexSignals)
                numIn=0;
                numOut=0;
            else
                numIn=numel(compiledPortComplexSignals.Inport);
                numOut=numel(compiledPortComplexSignals.Outport);
            end
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            if numIn==numel(portHandles.Inport)
                for i=1:numIn
                    inComplex=compiledPortComplexSignals.Inport(i);
                    if inComplex
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'ComplexBlockInport',...
                        num2str(i),...
                        aObj.ParentBlock().getName());
                        return
                    else
                        inType=compiledPortDataTypes.Inport{i};
                        if aObj.isComplexType(inType)
                            out=slci.compatibility.Incompatibility(...
                            aObj,...
                            'ComplexBlockInport',...
                            num2str(i),...
                            aObj.ParentBlock().getName());
                            return
                        end
                    end
                end
            end
            if numOut==numel(portHandles.Outport)
                for i=1:numOut
                    outComplex=compiledPortComplexSignals.Outport(i);
                    if outComplex
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'ComplexBlockOutport',...
                        num2str(i),...
                        aObj.ParentBlock().getName());
                        return
                    else
                        outType=compiledPortDataTypes.Outport{i};
                        if aObj.isComplexType(outType)
                            out=slci.compatibility.Incompatibility(...
                            aObj,...
                            'ComplexBlockOutport',...
                            num2str(i),...
                            aObj.ParentBlock().getName());
                            return
                        end
                    end
                end
            end
        end

    end

    methods(Access=private)


        function isComplex=isComplexType(aObj,typeStr)
            if~isKey(aObj.complexityTable,typeStr)
                resolvedType=aObj.resolve(typeStr);
                if isa(resolvedType,'Simulink.Bus')&&...
                    aObj.isBusComplexType(resolvedType)
                    isComplex=true;
                else
                    isComplex=false;
                end
                aObj.complexityTable(typeStr)=isComplex;
            end
            isComplex=aObj.complexityTable(typeStr);
        end


        function isComplex=isBusComplexType(~,busType)
            assert(isa(busType,'Simulink.Bus'));
            leafElements=busType.getLeafBusElements();
            numElements=numel(leafElements);
            for k=1:numElements
                leafel=leafElements(k);
                if strcmpi(leafel.Complexity,'Complex')
                    isComplex=true;
                    return;
                end
            end
            isComplex=false;

        end


        function resolved=resolve(aObj,var)
            try
                resolved=slResolve(var,aObj.ParentBlock().getSID());
            catch
                resolved=[];
            end
        end
    end
end

