classdef HasConnector < systemcomposer.query.Has
    %HASCONNECTOR Constraint that a component has a connector satisifying
    %the given sub-constraint.
    
    %   Copyright 2020 The MathWorks, Inc.
    
    properties
        AllowedParentConstraints = {
            ?systemcomposer.query.HasPort
        }
    end
    
    methods        
        function modelElems = doGetSatisfied(obj, arch, elemKindToFind, flattenReferences, varargin)
            import systemcomposer.query.internal.QueryUtils.*;
            
            modelElems = [];
            
            connElems = obj.SubConstraint.getSatisfied(arch, 'systemcomposer.arch.BaseConnector', ...
                flattenReferences, varargin{:});
            
            %Get all the connnectors which satisfy the constraint
            if isequal(elemKindToFind, 'systemcomposer.arch.BasePort')
                for idx = 1:numel(connElems)
                    connElem = connElems(idx);
                    %Get both the source and destination ports at the ends of
                    %these connectors
                    modelElems = [modelElems connElem.Ports]; %#ok<AGROW>
                end
                modelElems = getTopModelPortElems(modelElems, flattenReferences, varargin{:});
                modelElems = uniquifyPortElems(modelElems);
            elseif isequal(elemKindToFind, 'systemcomposer.arch.BaseComponent')
                for idx = 1:numel(connElems)
                    connElem = connElems(idx);
                    %Get the architecture elements owning the connector
                    modelElems = [modelElems connElem.Parent]; %#ok<AGROW>
                    modelElems = unique(modelElems);
                end
                modelElems = getTopModelCompElems(modelElems, flattenReferences, varargin{:});
            end
        end
        
        function tf = doIsSatisfied(obj, elem)
            % Look to see if the element has a connector which satisifes.
            tf = false;
            conns = [];
            if (isa(elem, 'systemcomposer.arch.BaseComponent'))
                arch = elem.Architecture;
                if ~isempty(arch)
                    conns = arch.Connectors;
                end
            elseif (isa(elem, 'systemcomposer.arch.ComponentPort'))
                conns = elem.Connectors;
            end
            
            for i = 1:numel(conns)
                tf = obj.SubConstraint.isSatisfied(conns(i));
                if (tf)
                    return;
                end
            end
        end
    end
end