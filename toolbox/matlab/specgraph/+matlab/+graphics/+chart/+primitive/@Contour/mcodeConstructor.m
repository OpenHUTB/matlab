function mcodeConstructor(this,code)




    setConstructorName(code,'contour')

    plotutils('makemcode',this,code)


    xName=get(this,'XDataSource');
    xName=code.cleanName(xName,'xdata');

    yName=get(this,'YDataSource');
    yName=code.cleanName(yName,'ydata');

    zName=get(this,'ZDataSource');
    zName=code.cleanName(zName,'zdata');


    ignoreProperty(code,'XData');
    ignoreProperty(code,'XDataMode');
    ignoreProperty(code,'XDataSource');
    if strcmp(this.XDataMode,'manual')
        arg=codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
        'Comment','contour x');
        addConstructorArgin(code,arg);
    end


    ignoreProperty(code,'YData');
    ignoreProperty(code,'YDataMode');
    ignoreProperty(code,'YDataSource');
    if strcmp(this.YDataMode,'manual')
        arg=codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true,...
        'Comment','contour y');
        addConstructorArgin(code,arg);
    end


    ignoreProperty(code,'ZData');
    ignoreProperty(code,'ZDataSource');
    arg=codegen.codeargument('Name',zName,'Value',this.ZData,'IsParameter',true,...
    'Comment','contour z');
    addConstructorArgin(code,arg);


    ignoreProperty(code,'LevelListMode');
    ignoreProperty(code,'LevelStepMode');
    ignoreProperty(code,'TextStepMode');



    ignoreProperty(code,'TextList');
    ignoreProperty(code,'TextListMode');
    ignoreProperty(code,'ShowText');


    generateDefaultPropValueSyntaxNoOutput(code);




    ContourData=codegen.codeargument('Name','c','Value',this.ContourMatrix,...
    'Comment','Contour data');
    ContourHandle=codegen.codeargument('Name','h','Value',this,...
    'Comment','Contour handle');
    addConstructorArgout(code,ContourData);
    addConstructorArgout(code,ContourHandle);

    if strcmp(this.ShowText,'on')


        clabelFunc=localCreateClabelCall(this,ContourData,ContourHandle);


        addPostConstructorFunction(code,clabelFunc);
    end


    function clabelFunc=localCreateClabelCall(this,ContourData,ContourHandle)

        clabelFunc=codegen.codefunction('Name','clabel');
        addArgin(clabelFunc,ContourData);
        addArgin(clabelFunc,ContourHandle);

        if strcmp(this.TextListMode,'manual')

            arg=codegen.codeargument('Name','TextLevels','Value',this.TextList,...
            'Comment','Contour text levels');
            addArgin(clabelFunc,arg);
        end


        localAddTextPropsToClabel(this,clabelFunc);


        function localAddTextPropsToClabel(this,func)



            textDefaults=matlab.graphics.chart.primitive.Contour.defaultLabelTextProperties();
            textProps=this.LabelTextProperties;


            localAddTextPropertyIfChanged(func,'FontName',textProps.Font.Name,textDefaults.Font.Name);
            localAddTextPropertyIfChanged(func,'FontSize',textProps.Font.Size,textDefaults.Font.Size);
            localAddTextPropertyIfChanged(func,'FontWeight',textProps.Font.Weight,textDefaults.Font.Weight);
            localAddTextPropertyIfChanged(func,'FontAngle',textProps.Font.Angle,textDefaults.Font.Angle);
            localAddTextPropertyIfChanged(func,'FontSmoothing',textProps.FontSmoothing,textDefaults.FontSmoothing);


            if strcmp(textProps.Visible,'off')
                localAddTextPropertyIfChanged(func,'Color','none','');
            else
                localAddTextPropertyIfChanged(func,'Color',textProps.ColorData,textDefaults.ColorData,@rgbConverter);
            end
            localAddTextPropertyIfChanged(func,'BackgroundColor',textProps.BackgroundColor,textDefaults.BackgroundColor,@rgbConverter);
            localAddTextPropertyIfChanged(func,'EdgeColor',textProps.EdgeColor,textDefaults.EdgeColor,@rgbConverter);


            localAddTextPropertyIfChanged(func,'LineStyle',textProps.LineStyle,textDefaults.LineStyle,@lineStyleConverter);
            localAddTextPropertyIfChanged(func,'LineWidth',textProps.LineWidth,textDefaults.LineWidth);


            localAddTextPropertyIfChanged(func,'Interpreter',textProps.Interpreter,textDefaults.Interpreter);
            localAddTextPropertyIfChanged(func,'Margin',textProps.Margin,textDefaults.Margin);


            function localAddTextPropertyIfChanged(func,prop,value,default,converterFunc)
                if~isequal(value,default)
                    if nargin>4

                        value=converterFunc(value);
                    end
                    arg=codegen.codeargument('Name','Text property name','Value',prop);
                    addArgin(func,arg);
                    arg=codegen.codeargument('Name','Text property value','Value',value);
                    addArgin(func,arg);
                end


                function rgb=rgbConverter(rgba)

                    rgb=double(rgba(1:3))./255;
                    rgb=rgb(:).';


                    function style=lineStyleConverter(style)

                        worldToUser=struct(...
                        'solid','-',...
                        'dashed','--',...
                        'dotted',':',...
                        'dashdot','-.',...
                        'none','none');

                        if isfield(worldToUser,style);
                            style=worldToUser.(style);
                        end
