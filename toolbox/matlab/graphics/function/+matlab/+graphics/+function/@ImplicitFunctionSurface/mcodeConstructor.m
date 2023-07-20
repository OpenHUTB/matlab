function mcodeConstructor(hObj,hCode)



    propsToIgnore={'Function'};

    constructor='fimplicit3';
    shortranges=false;
    if isequal(hObj.XRangeMode,'manual')&&...
        isequal(hObj.YRangeMode,'manual')&&isequal(hObj.ZRangeMode,'manual')
        shortranges=true;
        propsToIgnore=[propsToIgnore,{'XRange','YRange','ZRange'}];
    end

    setConstructorName(hCode,constructor);
    ignoreProperty(hCode,propsToIgnore);

    hFun=getConstructor(hCode);

    function addArg(name)
        hArg=codegen.codeargument('Value',hObj.(name),...
        'Name',name,'IsParameter',true);
        addArgin(hFun,hArg);
    end

    addArg('Function');

    if shortranges
        hArg=codegen.codeargument('Value',[hObj.XRange,hObj.YRange,hObj.ZRange],...
        'Name','parameter ranges','IsParameter',false);
        addArgin(hFun,hArg);
    end

    generateDefaultPropValueSyntax(hCode);
end
