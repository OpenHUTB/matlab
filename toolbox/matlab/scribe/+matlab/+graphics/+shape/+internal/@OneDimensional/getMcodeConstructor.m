function getMcodeConstructor(this,code,ShapeType)





    set(code,'Name',ShapeType);

    setConstructorName(code,'annotation');

    fig=ancestor(this,'figure');
    arg=codegen.codeargument('IsParameter',true,'Name','figure','Value',fig);
    addConstructorArgin(code,arg)

    arg=codegen.codeargument('Value',ShapeType);
    addConstructorArgin(code,arg);


    arg=codegen.codeargument('Value',this.NormX,'Name','X');
    addConstructorArgin(code,arg);
    arg=codegen.codeargument('Value',this.NormY,'Name','Y');
    addConstructorArgin(code,arg);

    ignoreProperty(code,'HitTest');
    ignoreProperty(code,'X');
    ignoreProperty(code,'Y');
    ignoreProperty(code,'Position');
    ignoreProperty(code,'Parent');


    generateDefaultPropValueSyntax(code);

end

