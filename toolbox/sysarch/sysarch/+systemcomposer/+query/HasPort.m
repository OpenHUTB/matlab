classdef HasPort < systemcomposer.query.Has
    %HASPORT Constraint that a component has a port satisifying the given
    %sub-constraint.
    
    %   Copyright 2019-2022 The MathWorks, Inc.
    
    properties
        AllowedParentConstraints = {}
    end
    
    methods

        function modelElems = doGetSatisfied(obj, arch, elemKindToFind, flattenReferences, varargin)
            modelElems = [];
            
            %Get all the ports which satisfy the constraint
            portElems = obj.SubConstraint.getSatisfied(arch, 'systemcomposer.arch.BasePort', ...
                flattenReferences, varargin{:});
            
            if isequal(elemKindToFind, 'systemcomposer.arch.BaseComponent')
                for idx = 1:numel(portElems)
                    portElem = portElems(idx);
                    %Get to the parent component from port
                    if isa(portElem, 'systemcomposer.arch.ArchitecturePort')
                        arch = portElem.Parent;
                        if isvalid(arch.Parent)
                            modelElems = [modelElems arch.Parent]; %#ok<AGROW>
                        end
                    else
                        modelElems = [modelElems portElem.Parent]; %#ok<AGROW>
                    end
                end
            end
            modelElems = unique(modelElems);
        end
        
        function tf = doIsSatisfied(obj, comp)
            % Look to see if it has a port which satisifes.
            tf = false;
            if (~isa(comp, 'systemcomposer.arch.BaseComponent'))
                % This only handles components as the passed in argument.
                return;
            end
            
            ports = comp.Ports;
            for i = 1:numel(ports)
                tf = obj.SubConstraint.isSatisfied(ports(i));
                if (tf)
                    return;
                end
            end
        end
        
        function negConstraint = isNegationConstraint(obj)
            negConstraint = obj.IsNot;
        end
    end

    methods (Hidden)
        function tf = isEvaluatedUsingNewSystem(obj)
            tf = obj.SubConstraint.isEvaluatedUsingNewSystem;
        end
    end
end

