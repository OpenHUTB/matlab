classdef Compare < systemcomposer.query.PropertyConstraint
    %COMPARE Property constraint which compares a property value to a given
    %value
    
    %   Copyright 2019-2022 The MathWorks, Inc.
    
    properties
        Value
        CompareFcnHdl;
    end
    
    methods
        function obj = Compare(prop, value, compareFcnHdl)
            obj@systemcomposer.query.PropertyConstraint(prop);
            obj.Value = value;
            obj.CompareFcnHdl = compareFcnHdl;
        end
        
        function v = getValue(obj)
            if (isa(obj.Value, 'systemcomposer.query.Value'))
                v = obj.Value.Val;
            else
                v = obj.Value;
            end
        end
    end
    
    methods (Hidden)
        function tf = isEvaluatedUsingNewSystem(obj)
            %If it is not a stereotype property, it is not evaluated using
            %the new system
            tf = true;
            if isempty(obj.Prop.ProfileName) || isempty(obj.Prop.StereotypeName)
                tf = false;
            end
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
            
            if isequal(elemKindToFind, 'systemcomposer.arch.BaseConnector')
                %Get all the connectors
                modelElems = getTopModelConnElems(filteredModelElems, flattenReferences, varargin{:});
            elseif isequal(elemKindToFind, 'systemcomposer.arch.BasePort')
                %Get all the ports
                modelElems = getTopModelPortElems(filteredModelElems, flattenReferences, varargin{:});
            elseif isequal(elemKindToFind, 'systemcomposer.arch.BaseComponent')
                %Get all the architectures
                modelElems = getTopModelCompElems(filteredModelElems, flattenReferences, varargin{:});
            end
        end
        
        function stereotypeNames = doGetSatisfiedStereotypeNames(obj, cache)
            stereotypeNames = [];
            %Get the cache entries which are the names of the stereotypes
            cacheEntries = cache.p_CacheEntries.keys;
            for idx= 1:numel(cacheEntries)
                cacheEntry = cacheEntries{idx};
                %Get the stereotype object and check if the property is the
                %one we are looking for
                stereotype = systemcomposer.profile.Stereotype.find(cacheEntry);
                try
                    if isequal(stereotype.get(obj.Prop.PropertyName), obj.getValue)
                        stereotypeNames = [stereotypeNames cacheEntry]; %#ok<AGROW>
                    end
                catch
                    %Invalid property. Ignore and move on.
                end
            end
        end
        
        function tf = doIsSatisfied(obj, elem)
            tf = false;
            [elemValue, units] = obj.Prop.getPropertyValue(elem);
            if (~isempty(elemValue) && ~isempty(obj.Value))
                % See if the LHS is a value object.
                if (isa(obj.Value, 'systemcomposer.query.Value'))
                    % This is a value object, we need to do some special
                    % things to the value before comparing
                    propDef = obj.Prop.getStereotypeProperty;
                    if ~isempty(units)
                        elemValue = propDef.getValueInUnits(elemValue, units, obj.Value.Units);
                    end
                end
                                
                try
                    tf = all(obj.CompareFcnHdl(elemValue, obj.getValue));
                catch
                    % It can fail when comparing two character arrays of
                    % different sizes.
                end
            elseif (func2str(obj.CompareFcnHdl) == "eq" && isempty(obj.Value) && isempty(elemValue))
                tf = true;
            elseif (func2str(obj.CompareFcnHdl) == "ne" && isempty(obj.Value) && ~isempty(elemValue))
                tf = true;
            end
        end
        
        function str = stringifyValueProp(obj)
            if (isa(obj.Value, 'systemcomposer.query.Value'))
                if (isempty(obj.Value.Units))
                    str = ['systemcomposer.query.Value(' obj.stringifyValue(obj.Value.Val) ')'];
                else
                    str = ['systemcomposer.query.Value(' obj.stringifyValue(obj.Value.Val) ',' '"' char(obj.Value.Units) '"' ')'];
                end
            else
                str = obj.stringifyValue(obj.Value);
            end
        end
        
        function str = stringifyValue(~, val)
            if isa(val, 'Simulink.IntEnumType')
                str = [metaclass(val).Name '.' char(val)];
            elseif (ischar(val) || isstring(val))
                str = ['"' char(val) '"'];
            elseif isempty(val)
                str = '[]';
            else
                str = num2str(val);
            end
        end
        
        function str = doStringify(obj)
            operator = func2str(obj.CompareFcnHdl);
            if strcmpi(operator, 'contains')
                str = [func2str(obj.CompareFcnHdl) '(' obj.Prop.stringify ',' obj.stringifyValueProp ')'];
            else
                operatorStr = '';
                switch operator
                    case 'eq'
                        operatorStr = '==';
                    case 'le'
                        operatorStr = '<=';
                    case 'lt'
                        operatorStr = '<';
                    case 'ge'
                        operatorStr = '>=';
                    case 'gt'
                        operatorStr = '>';
                    case 'ne'
                        operatorStr = '~=';
                end
                str = [obj.Prop.stringify ' ' operatorStr ' ' obj.stringifyValueProp];
            end
        end
    end
end

