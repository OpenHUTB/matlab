classdef IsInRange < systemcomposer.query.PropertyConstraint
    %ISINRANGE Property constraint which verifies that a property value is
    %within a given range.
    
    %   Copyright 2019-2022 The MathWorks, Inc.
    
    properties
        BeginRangeValue
        EndRangeValue
    end
    
    methods
        function obj = IsInRange(prop, beginRangeValue, endRangeValue)
            systemcomposer.internal.verifyAPIArgumentType(prop, ...
                1, 'systemcomposer.query.PropertyValue');
            
            obj@systemcomposer.query.PropertyConstraint(prop);
            
            systemcomposer.internal.verifyAPIArgumentType(beginRangeValue, ...
                2, 'systemcomposer.query.Value');
            systemcomposer.internal.verifyAPIArgumentType(endRangeValue, ...
                3, 'systemcomposer.query.Value');
            
            obj.BeginRangeValue = beginRangeValue;
            obj.EndRangeValue = endRangeValue;
        end
    end
    
    methods (Hidden)

        function tf = isEvaluatedUsingNewSystem(obj)
            tf = true;
        end

        function modelElems = doGetSatisfied(obj, arch, elemKindToFind, flattenReferences, varargin)        
            import systemcomposer.query.internal.QueryUtils.*;
            
            modelElems = [];
            cache = arch.getImpl.getProfileNamespace.p_PrototypeToPrototypableCache;
            
            implModelElems = cache.getElementsWithPrototype([obj.Prop.ProfileName '.' obj.Prop.StereotypeName]);

            %Filter model elems based on the type
            for implModelElem = implModelElems
                modelElem = systemcomposer.internal.getWrapperForImpl(implModelElem);
                elemKind = elemKindToFind;
                if isequal(elemKindToFind, 'systemcomposer.arch.BaseComponent')
                    elemKind = 'systemcomposer.arch.Architecture';
                end
                if isa(modelElem, elemKind)
                    modelElems = [modelElems modelElem]; %#ok<AGROW>
                end
            end
            
            filteredModelElems = [];
            for modelElem = modelElems
                if obj.isSatisfied(modelElem)
                    filteredModelElems = [filteredModelElems modelElem]; %#ok<AGROW>                   
                end
            end

            if isequal(elemKindToFind, 'systemcomposer.arch.BasePort')
                %Get all the ports
                modelElems = getTopModelPortElems(filteredModelElems, flattenReferences, varargin{:});
            elseif isequal(elemKindToFind, 'systemcomposer.arch.BaseComponent')
                %Get all the architectures
                modelElems = getTopModelCompElems(filteredModelElems, flattenReferences, varargin{:});
            end
        end
        
        function tf = doIsSatisfied(obj, elem)
            tf = false;
            [elemValue, units] = obj.Prop.getPropertyValue(elem);
            if (~isempty(elemValue))
                propDef = obj.Prop.getStereotypeProperty;
                % Get the value in the begin range units
                if ~isempty(units) && ~isempty(obj.BeginRangeValue.Units)
                    elemValue = propDef.getValueInUnits(elemValue, units, obj.BeginRangeValue.Units);
                end
                
                % Ensure it is above the begin range value
                tf = elemValue >= obj.BeginRangeValue.Val;
                if (~tf)
                    return;
                end
                
                % Get the value again in the end range units
                if ~isempty(units) && ~isempty(obj.EndRangeValue.Units)
                    elemValue = propDef.getValueInUnits(elemValue, units, obj.EndRangeValue.Units);
                end
                
                % Ensure it is below the end range value
                tf = elemValue <= obj.EndRangeValue.Val;
            end
        end
        
        function str = doStringify(obj)
            str = [metaclass(obj).Name '(' obj.Prop.stringify ',' obj.BeginRangeValue.stringify  ',' obj.EndRangeValue.stringify ')'];
        end
    end
end

