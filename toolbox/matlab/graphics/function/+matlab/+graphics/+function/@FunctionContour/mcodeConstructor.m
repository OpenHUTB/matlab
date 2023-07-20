function mcodeConstructor(hObj,hCode)



    propsToIgnore={'Function'};
    setConstructorName(hCode,'fcontour');

    ignoreProperty(hCode,propsToIgnore);

    hFun=getConstructor(hCode);

    hArg=codegen.codeargument(...
    'Value',hObj.Function,...
    'Name','internal_function','IsParameter',true,...
    'Comment','Function f(x)');
    addArgin(hFun,hArg);

    generateDefaultPropValueSyntax(hCode);
end
