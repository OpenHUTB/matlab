function res=objectIsValidTerminator(obj)




    res=~isempty(obj)&&(isa(obj,'SLM3I.Terminator')||isa(obj,'SLM3I.ImmutableTerminator'))&&isvalid(obj);
end
