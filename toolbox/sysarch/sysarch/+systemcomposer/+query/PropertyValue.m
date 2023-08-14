classdef PropertyValue < systemcomposer.query.BaseProperty
    %PROPERTYVALUE This class will retrieve a property from a systemcomposer
    %object or a sterotype property and will then evaluate the property
    %value.
    
    %   Copyright 2019 The MathWorks, Inc.
    
    methods
        function [value, unit] = getPropertyValue(obj, elem)
            %GETPROPERTYVALUE Get the evaluated value of the property.
            
            value = [];
            unit = [];
            try
                if obj.IsElemProperty
                    value = get(elem, obj.PropertyName);
                elseif obj.IsStereotypeProperty
                    [~, unit] = elem.getProperty(obj.FullPropName);
                    value = elem.getEvaluatedPropertyValue(obj.FullPropName);
                end
            catch
                % Invalid property, ignore and move on.
            end
        end
    end
    
    methods (Hidden)
        function str = stringify(obj)
            str = ['systemcomposer.query.PropertyValue(' ['"' char(obj.FullPropName) '"'] ')'];
        end
    end
    
    % Operator overloads
    methods
        function c = eq(prop, value)
            c = systemcomposer.query.Compare(prop, value, @eq);
        end
        
        function c = le(prop, value)
            c = systemcomposer.query.Compare(prop, value, @le);
        end
        
        function c = lt(prop, value)
            c = systemcomposer.query.Compare(prop, value, @lt);
        end
        
        function c = ge(prop, value)
            c = systemcomposer.query.Compare(prop, value, @ge);
        end
        
        function c = gt(prop, value)
            c = systemcomposer.query.Compare(prop, value, @gt);
        end
        
        function c = ne(prop, value)
            c = systemcomposer.query.Compare(prop, value, @ne);
        end
        
        function c = contains(prop, value)
            c = systemcomposer.query.Compare(prop, value, @contains);
        end
    end
end

