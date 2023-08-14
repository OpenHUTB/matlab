function groups=getCustomPropertyGroup(prob)











    groups.Description=prob.Description;
    groups.Variables=prob.Variables;
    groups.Equations=prob.Equations;
    groups=matlab.mixin.util.PropertyGroup(groups);