function mcodeConstructor(hObj,hCode)



    setConstructorName(hCode,'fimplicit');


    propsToIgnore={'Function','XRange','YRange'};

    ignoreProperty(hCode,propsToIgnore);

    hFun=getConstructor(hCode);

    hArg=codegen.codeargument(...
    'Value',hObj.Function,...
    'Name','function','IsParameter',true,...
    'Comment','Function f(x,y)');
    addArgin(hFun,hArg);

    if isequal(hObj.XRangeMode,'manual')||isequal(hObj.YRangeMode,'manual')
        if isequal(hObj.XRange,hObj.YRange)
            hArg=codegen.codeargument('Value',hObj.XRange,...
            'Name','x/y range','IsParameter',false);
        else
            hArg=codegen.codeargument('Value',[hObj.XRange,hObj.YRange],...
            'Name','x/y range','IsParameter',false);
        end
        addArgin(hFun,hArg);
    end

    generateDefaultPropValueSyntax(hCode);
end
