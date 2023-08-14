classdef (Abstract) BaseProperty
    %BASEPROPERTY This is the base class for all systemcomposer.query.*
    %property classes.
    
    %   Copyright 2019 The MathWorks, Inc.
    
    properties
        PropertyName;
        IsElemProperty = false;
        IsStereotypeProperty = false;
        ProfileName;
        StereotypeName;
        FullPropName;
    end
    
    methods
        function obj = BaseProperty(propertyName)
            obj.FullPropName = propertyName;
            names = strsplit(propertyName, '.');
            if (numel(names) == 1)
                obj.IsElemProperty = true;
                obj.PropertyName = propertyName;
            elseif (numel(names) == 3)
                obj.IsStereotypeProperty = true;
                obj.ProfileName = names{1};
                obj.StereotypeName = names{2};
                obj.PropertyName = names{3};
            else
                systemcomposer.internal.throwAPIError('InvPropNameString', propertyName);
            end
        end
        
        function tf = hasProperty(obj, elem)
            tf = false;
            if (obj.isElemProperty)
                tf = ~isempty(elem.findprop(obj.PropertyName));
            elseif obj.isStereotypeProperty
                tf = ~isempty(elem.getProperty(obj.PropertyName));
            end
        end
        
        function prop = getStereotypeProperty(obj)
            prop = [];
            profile = systemcomposer.profile.Profile.find(obj.ProfileName);
            if ~isempty(profile)
                stereotype = profile.getStereotype(obj.StereotypeName);
                if ~isempty(stereotype)
                    prop = stereotype.findProperty(obj.PropertyName);
                end
            end
        end
    end
    
    methods (Abstract)
        [value, unit] = getPropertyValue(obj, elem);
    end
end

