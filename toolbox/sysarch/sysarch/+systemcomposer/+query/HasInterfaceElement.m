classdef HasInterfaceElement < systemcomposer.query.Has
    %HASINTERFACEELEMENT Constraint that a interface has an interface element
    %satisifying the given sub-constraint.
    
    %   Copyright 2019 The MathWorks, Inc.
    
    properties
        AllowedParentConstraints = {
            ?systemcomposer.query.HasInterface, ...
        }
    end
    
    methods
        function tf = doIsSatisfied(obj, intrf)
            % Look to see if it has an interface which satisifes.
            tf = false;
            if (~isa(intrf, 'systemcomposer.interface.DataInterface'))
                % This only handles data interfaces as the passed in argument.
                return;
            end
            
            elements = intrf.Elements;
            for i = 1:numel(elements)
                tf = obj.SubConstraint.isSatisfied(elements(i).Type);
                if (tf)
                    return;
                end
            end
        end
    end
end
