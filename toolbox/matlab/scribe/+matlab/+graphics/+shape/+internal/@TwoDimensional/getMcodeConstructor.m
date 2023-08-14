function getMcodeConstructor(this,code,ShapeType)





    set(code,'Name',ShapeType);

    setConstructorName(code,'annotation');

    fig=ancestor(this,'figure');
    arg=codegen.codeargument('IsParameter',true,'Name','figure','Value',fig);
    addConstructorArgin(code,arg)

    arg=codegen.codeargument('Value',ShapeType);
    addConstructorArgin(code,arg);

    propsToIgnore={'HitTest','Parent'};
    ignoreProperty(code,propsToIgnore);



    if isprop(this,'String')
        str=get(this,'String');
        if isempty(str)
            ignoreProperty(code,'String');
        elseif strcmpi('textbox',ShapeType)&&(~iscell(str)||(iscell(str)&&~isempty([str{:}])))





            addProperty(code,'String');
        end
    end



    hPos=get(this,'Position');
    hPos=hgconvertunits(fig,hPos,get(this,'Units'),'Normalized',fig);
    arg2=codegen.codeargument('Name','position','Value',hPos);
    addConstructorArgin(code,arg2);
    ignoreProperty(code,'Position');


    generateDefaultPropValueSyntax(code);

end

