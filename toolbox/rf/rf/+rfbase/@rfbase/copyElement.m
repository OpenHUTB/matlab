function copyObj=copyElement(h)






    copyObj=copyElement@matlab.mixin.Copyable(h);


    hmetainfo=metaclass(h);
    metaprops={hmetainfo.PropertyList.Name};
    handleProps=metaprops(cellfun(@(x)isa(h.(x),'handle'),metaprops));
    for idx=1:length(handleProps)
        propName=handleProps{idx};
        copyObj.(propName)=copy(h.(propName));
    end
end