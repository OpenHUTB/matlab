classdef Property < systemcomposer.query.BaseProperty
    %PROPERTY This class will retrieve a property from a systemcomposer
    %object or a sterotype property and will not evaluate the property
    %value. The value returned will always be a string or character array.
    
    %   Copyright 2019 The MathWorks, Inc.
    
    methods
        function [value, unit] = getPropertyValue(obj, elem)
            %GETPROPERTYVALUE Get the non-evaluated value of the property.
            %The value returned will always be a string or character array.
            
            value = [];
            unit = [];
            try
                if obj.IsElemProperty
                    value = get(elem, obj.PropertyName);
                elseif obj.IsStereotypeProperty
                    [value, unit] = elem.getProperty(obj.FullPropName);
                end
            catch
                % Invalid property. Ignore and move on.
            end
        end
    end
    
    methods (Hidden)
        function str = stringify(obj)
            str = ['systemcomposer.query.Property(' ['"' char(obj.FullPropName) '"'] ')'];
        end
    end
    
    % Operator overloads
    methods
        function c = eq(prop, value)
            c = systemcomposer.query.Compare(prop, value, @eq);
        end
        
        function c = ne(prop, value)
            c = systemcomposer.query.Compare(prop, value, @ne);
        end
        
        function c = contains(prop, value)
            c = systemcomposer.query.Compare(prop, value, @contains);
        end
    end
end

