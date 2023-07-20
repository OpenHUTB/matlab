function res=objectIsValidPort(obj)




    res=~isempty(obj)&&(isa(obj,'SLM3I.Port')||isa(obj,'SLM3I.ImmutablePort'))&&isvalid(obj);

end
