function res=objectIsValidBlock(obj)




    res=~isempty(obj)&&(isa(obj,'SLM3I.Block')||isa(obj,'SLM3I.ImmutableBlock'))&&isvalid(obj);
end
