function mcodeConstructor(hObj,hCode)



    propsToIgnore={};
    if isequal(hObj.ZFunction,[])
        setConstructorName(hCode,'fplot');
    else
        setConstructorName(hCode,'fplot3');
    end


    propsToIgnore=[{'XFunction','YFunction','ZFunction','TRange'},...
    propsToIgnore];

    ignoreProperty(hCode,propsToIgnore);

    hFun=getConstructor(hCode);

    function addArg(name)
        hArg=codegen.codeargument('Value',hObj.(name),...
        'Name',name,'IsParameter',true,...
        'Comment',['fplot ',name]);
        addArgin(hFun,hArg);
    end

    addArg('XFunction');
    addArg('YFunction');
    if~isequal(hObj.ZFunction,[])
        addArg('ZFunction');
    end

    if isequal(hObj.TRangeMode,'manual')
        hArg=codegen.codeargument('Value',hObj.TRange,...
        'Name','parameter range','IsParameter',false);
        addArgin(hFun,hArg);
    end

    generateDefaultPropValueSyntax(hCode);
end
