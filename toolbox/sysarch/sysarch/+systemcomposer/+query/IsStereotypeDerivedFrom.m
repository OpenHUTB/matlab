classdef IsStereotypeDerivedFrom < systemcomposer.query.Constraint
    %ISTEREOTYPEDERIVEDFROM Constraint which verifies that a stereotype is
    %derived from a given stereotype.
    
    %   Copyright 2019-2022 The MathWorks, Inc.
    
    properties
        BaseStereotypeName;
    end
    
    methods
        function obj = IsStereotypeDerivedFrom(baseStereotypeName)
            % Validate the argument
            systemcomposer.internal.verifyAPIArgumentType(baseStereotypeName, ...
                    1, {'string', 'char'});
            obj.BaseStereotypeName = baseStereotypeName;
        end
    end
    
    methods (Hidden)
        function tf = isEvaluatedUsingNewSystem(obj)
            tf = true;
        end

        function str = doStringify(obj)
            str = [metaclass(obj).Name '("' obj.BaseStereotypeName '")'];
        end
        
        function stereotypeNames = doGetSatisfiedStereotypeNames(obj, ~)
            stereotypeNames = obj.BaseStereotypeName;
        end
        
        function tf = doIsSatisfied(obj, stereotype)
            % Look to see if the passed in stereotype is derived form the given value.
            tf = false;
            if (~isa(stereotype, 'systemcomposer.profile.Stereotype'))
                % This only handles stereotypes as the passed in argument.
                return;
            end
            
            baseStereotypeObj = systemcomposer.profile.Stereotype.find(obj.BaseStereotypeName);
            if ~isempty(baseStereotypeObj)
                tf = stereotype.isDerivedFrom(baseStereotypeObj);
            end
        end
    end
end

