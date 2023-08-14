function res=objectIsValidLine(obj)




    res=~isempty(obj)&&(isa(obj,'SLM3I.Line')||isa(obj,'SLM3I.ImmutableLine'))&&isvalid(obj);
end
