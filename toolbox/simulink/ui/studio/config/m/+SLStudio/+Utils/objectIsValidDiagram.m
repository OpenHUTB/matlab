function res=objectIsValidDiagram(obj)




    res=~isempty(obj)&&(isa(obj,'GLUE2.Diagram')||isa(obj,'GLUE2.ImmutableDiagram'))&&isvalid(obj);
end
