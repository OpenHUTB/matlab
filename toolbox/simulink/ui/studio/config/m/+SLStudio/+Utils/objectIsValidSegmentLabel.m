function res=objectIsValidSegmentLabel(obj)




    res=~isempty(obj)&&(isa(obj,'SLM3I.SegmentLabel')||isa(obj,'SLM3I.ImmutableSegmentLabel'))&&isvalid(obj);
end
