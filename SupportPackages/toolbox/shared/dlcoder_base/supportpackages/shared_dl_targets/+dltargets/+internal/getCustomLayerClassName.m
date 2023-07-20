function cppClassName=getCustomLayerClassName(layer)
    cppClassNameTmp=split(class(layer),'.');




    cppClassName=cppClassNameTmp{end};
end

