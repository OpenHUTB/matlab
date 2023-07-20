classdef (Abstract) PropertyConstraint < systemcomposer.query.Constraint
    %PROPERTYCONSTRAINT Base class for all constraints in which the left
    %hand side of the constraint is a systemcomposer.query.Property.
    
    %   Copyright 2019 The MathWorks, Inc.
    
    properties
        Prop;
    end
    
    methods
        function obj = PropertyConstraint(prop)
            obj.validateProp(prop);
            obj.Prop = prop;
        end
    end
    
    
    methods (Access = private)
        function validateProp(~, prop)
            systemcomposer.internal.verifyAPIArgumentType(prop, ...
                    2, 'systemcomposer.query.BaseProperty');
        end
    end
end
