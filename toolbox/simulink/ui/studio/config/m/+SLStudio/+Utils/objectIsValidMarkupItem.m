function res=objectIsValidMarkupItem(obj)




    res=~isempty(obj)&&(isa(obj,'markupM3I.MarkupItem')||isa(obj,'markupM3I.ImmutableMarkupItem'))&&isvalid(obj);
end
