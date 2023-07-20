function mcodeConstructor(this,code)






    setConstructorName(code,'legend');
    set(code,'Name','legend');


    ax=this.Axes;
    arg=codegen.codeargument('IsParameter',true,'Name','axes','Value',ax);
    addConstructorArgin(code,arg);


    arg=codegen.codeargument('Value','show');
    addConstructorArgin(code,arg);
    propsToIgnore={};
    propsToAdd={};

    if strcmp(get(this,'Location'),'none')
        propsToIgnore={'Location','OuterPosition'};
        propsToAdd={'Position'};
    else
        if~is2D(ax)
            if strcmpi(this.Location,'NorthEastOutside')
                propsToIgnore={'Location'};
            else
                propsToAdd={'Location'};
            end
        else
            if strcmpi(this.Location,'NorthEast')
                propsToIgnore={'Location'};
            else
                propsToAdd={'Location'};
            end
        end
        propsToIgnore=[propsToIgnore,{'OuterPosition','Position'}];
    end
    propsToIgnore=[{'Parent','Layer',...
    'Title','XLabel','YLabel',...
    'YAxisLocation','YLim','ZLabel','ButtonDownFcn',...
    'SelectionHighlight','Tag','Box','NextPlot','XTick',...
    'YTick','UserData','String','Interruptible','XLim','CLim',...
    'YTickLabel','XTickLabel','ItemHitFcn','Layout'},propsToIgnore];


    if~strcmpi(this.FontName,get(ax,'FontName'))
        propsToAdd{end+1}='FontName';
    else
        propsToIgnore{end+1}='FontName';
    end
    if~strcmpi(this.FontAngle,get(ax,'FontAngle'));
        propsToAdd{end+1}='FontAngle';
    else
        propsToIgnore{end+1}='FontAngle';
    end
    if~isequal(this.FontWeight,get(ax,'FontWeight'));
        propsToAdd{end+1}='FontWeight';
    else
        propsToIgnore{end+1}='FontWeight';
    end
    if~isequal(this.Color,get(ax,'Color'));
        if strcmpi(get(ax,'Color'),'none')
            fig=ancestor(ax,'Figure');
            if~isequal(this.Color,get(fig,'Color'))
                propsToAdd{end+1}='Color';
            else
                propsToIgnore{end+1}='Color';
            end
        else
            propsToAdd{end+1}='Color';
        end
    else
        propsToIgnore{end+1}='Color';
    end
    ignoreProperty(code,propsToIgnore);
    addProperty(code,propsToAdd);



    hFunc=code.Constructor;
    hArg=codegen.codeargument('Value',this,...
    'Name',get(hFunc,'Name'));
    addArgout(hFunc,hArg);


    localCallSet(code);


    if~isempty(this.Title_I)&&~isempty(this.Title.String)
        hTitleFunc=codegen.codefunction('Name','title');
        titleArg=codegen.codeargument('IsParameter',true,'Value',this);
        titleValArg=codegen.codeargument('ArgumentType',codegen.ArgumentType.PropertyValue,'Value',this.Title.String);
        hTitleFunc.addArgin(titleArg);
        hTitleFunc.addArgin(titleValArg);
        code.addPostConstructorFunction(hTitleFunc);
    end




    if strncmp(fliplr(get(this,'Location')),'edistuO',7)
        if~isappdata(double(ax),'LegendColorbarExpectedPosition')||...
            ~isequal(getappdata(double(ax),'LegendColorbarExpectedPosition'),get(ax,'Position'))
            axPos=get(ax,'Position');
            code.addPostConstructorText(sprintf('%% Resize the axes in order to prevent it from shrinking.'));
            hFunc=codegen.codefunction('Name','set');
            axArg=codegen.codeargument('IsParameter',true,'Name','axes','Value',ax);
            propArg=codegen.codeargument('Value','Position','ArgumentType',codegen.ArgumentType.PropertyName);
            valArg=codegen.codeargument('ArgumentType',codegen.ArgumentType.PropertyValue,'Value',axPos);
            hFunc.addArgin(axArg);
            hFunc.addArgin(propArg);
            hFunc.addArgin(valArg);
            code.addPostConstructorFunction(hFunc);
        end
    end


    function localCallSet(code)



        hMomento=get(code,'MomentoRef');
        hObj=get(hMomento,'ObjectRef');
        hPropList=get(hMomento,'PropertyObjects');


        hArg=codegen.codeargument('Value',hObj,'IsParameter',true);

        hSetFunc=codegen.codefunction.createSetCall(hArg,hPropList,'legend');
        code.addPostConstructorFunction(hSetFunc);
