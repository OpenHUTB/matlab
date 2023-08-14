classdef WLConstraintGenerator<handle




    methods(Abstract)
        constraints=getConstraints(this,problemObject,options);
    end
end
