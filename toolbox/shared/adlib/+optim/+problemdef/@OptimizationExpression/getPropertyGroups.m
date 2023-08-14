function groups=getPropertyGroups(obj)











    groups.IndexNames=obj.IndexNames;
    groups.Variables=obj.Variables;
    groups=matlab.mixin.util.PropertyGroup(groups);