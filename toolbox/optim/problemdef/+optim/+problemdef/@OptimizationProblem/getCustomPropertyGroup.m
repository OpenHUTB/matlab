function groups=getCustomPropertyGroup(prob)











    groups.Description=prob.Description;
    groups.ObjectiveSense=prob.ObjectiveSense;
    groups.Variables=prob.Variables;
    groups.Objective=prob.Objective;
    groups.Constraints=prob.Constraints;
    groups=matlab.mixin.util.PropertyGroup(groups);