function mcodeConstructor(this,code)










    setConstructorName(code,'colorbar');



    ax=this.Axes;
    arg=codegen.codeargument('IsParameter',true,'Name','axes','Value',ax);
    addConstructorArgin(code,arg);

    if~strcmpi(this.Location,'manual')
        hLocProp=findprop(this,'Location_I');
        if~strcmpi(this.Location,hLocProp.DefaultValue)
            arg=codegen.codeargument('IsParameter',false,'Name','Location','Value',get(this,'Location'));
            addConstructorArgin(code,arg);
        end
    else
        arg=codegen.codeargument('IsParameter',false,'Name','PositionString','Value','Position');
        addConstructorArgin(code,arg);
        arg=codegen.codeargument('IsParameter',false,'Name','Position','Value',this.Position);
        addConstructorArgin(code,arg);
    end

    propsToIgnore={'Parent','Axes',...
    'Position','Title','XLabel',...
    'YLabel','ButtonDownFcn','SelectionHighlight','Tag',...
    'Interruptible','Location','Box',...
    'XTick','YTick','TickDirection','Layout'};
    propsToAdd={};


    if~strcmp(this.ColorMode,'auto')
        propsToAdd{end+1}='Color';
    else
        propsToIgnore{end+1}='Color';
    end

    ignoreProperty(code,propsToIgnore);
    addProperty(code,propsToAdd);


    generateDefaultPropValueSyntax(code);




    if strncmp(fliplr(get(this,'Location')),'edistuO',7)...
        &&(~isappdata(ax,'LegendColorbarExpectedPosition')||...
        ~isequal(getappdata(ax,'LegendColorbarExpectedPosition'),ax.Position))...
        &&strcmpi(ax.ActivePositionProperty,'Position')

        axPos=ax.Position;
        code.addPostConstructorText('% Resize the axes in order to prevent it from shrinking.');
        hFunc=codegen.codefunction('Name','set');
        axArg=codegen.codeargument('IsParameter',true,'Name','axes','Value',ax);
        propArg=codegen.codeargument('Value','Position','ArgumentType','PropertyName');
        valArg=codegen.codeargument('ArgumentType','PropertyValue','Value',axPos);
        hFunc.addArgin(axArg);
        hFunc.addArgin(propArg);
        hFunc.addArgin(valArg);
        code.addPostConstructorFunction(hFunc);
    end
