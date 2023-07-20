function res=objectIsValidSegment(obj)




    res=~isempty(obj)&&(isa(obj,'SLM3I.Segment')||isa(obj,'SLM3I.ImmutableSegment'))&&isvalid(obj);
end
