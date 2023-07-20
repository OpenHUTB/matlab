function res=objectIsValidState(obj)




    res=~isempty(obj)&&(isa(obj,'StateflowDI.State')||isa(obj,'StateflowDI.ImmutableState'))&&isvalid(obj);
end
