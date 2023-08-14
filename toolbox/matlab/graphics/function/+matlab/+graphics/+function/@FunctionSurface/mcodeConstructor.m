function mcodeConstructor(hObj,hCode)



    propsToIgnore={'Function'};

    constructor='fsurf';
    hparent=ancestor(hObj,'axes');
    if~isempty(hparent)
        fc=get(hparent,'Color');
        if strcmpi(fc,'none')
            hparent=ancestor(hObj,'figure');
            if isprop(hparent,'Color')
                fc=get(hparent,'Color');
            elseif isprop(hparent,'BackgroundColor')
                fc=get(hparent,'BackgroundColor');
            end
        end
        if isequal(hObj.FaceColor,fc)&&isequal(hObj.EdgeColor,'interp')
            constructor='fmesh';
            propsToIgnore=[propsToIgnore,{'FaceColor','EdgeColor'}];
        end
    end

    shortranges=false;
    if isequal(hObj.XRangeMode,'manual')&&isequal(hObj.YRangeMode,'manual')
        shortranges=true;
        propsToIgnore=[propsToIgnore,{'XRange','YRange'}];
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
        hArg=codegen.codeargument('Value',[hObj.XRange,hObj.YRange],...
        'Name','parameter ranges','IsParameter',false);
        addArgin(hFun,hArg);
    end

    generateDefaultPropValueSyntax(hCode);
end
