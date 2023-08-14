function handleprops=gethandleprops(h)





    hmetainfo=metaclass(h);
    metaprops=cell(1,length(hmetainfo.PropertyList));
    [metaprops{:}]=hmetainfo.PropertyList.Name;
    handleprops=metaprops(cellfun(@(x)isa(h.(x),'handle'),metaprops));

end