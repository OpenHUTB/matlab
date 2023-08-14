function mcodeConstructor(this,code)




    is3D=~isempty(this.ZData);

    if is3D
        setConstructorName(code,'quiver3')
        constName='quiver3';
    else
        setConstructorName(code,'quiver')
        constName='quiver';
    end

    plotutils('makemcode',this,code)

    ignoreProperty(code,{'XData','YData','ZData',...
    'XDataMode','YDataMode',...
    'XDataSource','YDataSource',...
    'ZDataSource','UDataSource',...
    'VDataSource','WDataSource',...
    'UData','VData','WData'});


    if strcmp(this.XDataMode,'manual')

        xName=get(this,'XDataSource');
        xName=code.cleanName(xName,'X');

        arg=codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
        'Comment',[constName,' X']);
        addConstructorArgin(code,arg);
    end


    if strcmp(this.YDataMode,'manual')

        yName=get(this,'YDataSource');
        yName=code.cleanName(yName,'Y');

        arg=codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true,...
        'Comment',[constName,' Y']);
        addConstructorArgin(code,arg);
    end


    if is3D

        zName=get(this,'ZDataSource');
        zName=code.cleanName(zName,'Z');

        arg=codegen.codeargument('Name',zName,'Value',this.ZData,'IsParameter',true,...
        'Comment',[constName,' Z']);
        addConstructorArgin(code,arg);
    end



    uName=get(this,'UDataSource');
    uName=code.cleanName(uName,'U');

    arg=codegen.codeargument('Name',uName,'Value',this.UData,'IsParameter',true,...
    'Comment',[constName,' U']);
    addConstructorArgin(code,arg);



    vName=get(this,'VDataSource');
    vName=code.cleanName(vName,'V');

    arg=codegen.codeargument('Name',vName,'Value',this.VData,'IsParameter',true,...
    'Comment',[constName,' V']);
    addConstructorArgin(code,arg);


    if is3D

        wName=get(this,'WDataSource');
        wName=code.cleanName(wName,'W');

        arg=codegen.codeargument('Name',wName,'Value',this.WData,'IsParameter',true,...
        'Comment',[constName,' W']);
        addConstructorArgin(code,arg);
    end


    if strcmpi(this.ColorMode,'auto')
        ignoreProperty(code,'Color')
    end

    generateDefaultPropValueSyntax(code);
