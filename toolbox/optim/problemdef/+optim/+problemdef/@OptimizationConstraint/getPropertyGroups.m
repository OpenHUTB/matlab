function groups=getPropertyGroups(con)








    groups.IndexNames=con.IndexNames;
    groups.Variables=con.Variables;
    groups=matlab.mixin.util.PropertyGroup(groups);

