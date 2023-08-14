function res=objectIsValidAnnotation(obj)




    res=~isempty(obj)&&(isa(obj,'SLM3I.Annotation')||isa(obj,'SLM3I.ImmutableAnnotation'))&&isvalid(obj);
end
