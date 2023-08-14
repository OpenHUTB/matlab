function mcodeConstructor(hObj,hCode)



    setConstructorName(hCode,'fplot');


    propsToIgnore={'Function','XRange'};

    ignoreProperty(hCode,propsToIgnore);

    hFun=getConstructor(hCode);

    hArg=codegen.codeargument(...
    'Value',hObj.Function,...
    'Name','function','IsParameter',true,...
    'Comment','Function f(x)');
    addArgin(hFun,hArg);

    if isequal(hObj.XRangeMode,'manual')
        hArg=codegen.codeargument('Value',hObj.XRange,...
        'Name','x range','IsParameter',false);
        addArgin(hFun,hArg);
    end

    generateDefaultPropValueSyntax(hCode);
end
