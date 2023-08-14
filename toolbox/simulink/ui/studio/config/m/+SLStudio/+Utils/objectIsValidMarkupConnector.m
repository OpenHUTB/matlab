function res=objectIsValidMarkupConnector(obj)




    res=~isempty(obj)&&(isa(obj,'markupM3I.MarkupConnector')||isa(obj,'markupM3I.ImmutableMarkupConnector'))&&isvalid(obj);
end
