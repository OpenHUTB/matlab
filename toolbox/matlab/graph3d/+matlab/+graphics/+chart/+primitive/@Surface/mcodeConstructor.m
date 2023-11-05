function mcodeConstructor(hObj,hCode)

    propsToIgnore={};

    edgecolor=get(hObj,'EdgeColor');
    facelighting=get(hObj,'FaceLighting');
    edgelighting=get(hObj,'EdgeLighting');
    if strcmp(edgecolor,'flat')&&...
        strcmp(facelighting,'none')&&...
        strcmp(edgelighting,'flat')
        propsToIgnore={propsToIgnore{:},...
        'FaceColor','EdgeColor',...
        'FaceLighting','EdgeLighting'};
        constructor_name='mesh';
    else
        constructor_name='surf';
    end
    setConstructorName(hCode,constructor_name);



    propsToIgnore={'XDataMode','YDataMode','CDataMode',...
    'XDataSource','YDataSource','CDataSource','ZDataSource',...
    propsToIgnore{:}};
    if strmatch(get(hObj,'DisplayName'),get(hObj,'ZDataSource'))
        propsToIgnore{end+1}='DisplayName';
    end
    ignoreProperty(hCode,propsToIgnore);






    xdata=get(hObj,'xdata');
    ydata=get(hObj,'ydata');
    zdata=get(hObj,'zdata');
    cdata=get(hObj,'cdata');

    m=size(zdata,1);
    n=size(zdata,2);

    is_default_xdata=isequal((1:n),xdata);
    is_default_ydata=isequal((1:m)',ydata);
    is_default_cdata=isequal(zdata,cdata);


    xName=get(hObj,'XDataSource');
    xName=hCode.cleanName(xName,'xdata');

    yName=get(hObj,'YDataSource');
    yName=hCode.cleanName(yName,'ydata');

    zName=get(hObj,'ZDataSource');
    zName=hCode.cleanName(zName,'zdata');

    cName=get(hObj,'CDataSource');
    cName=hCode.cleanName(cName,'cdata');

    ignoreProperty(hCode,{'XData','YData','ZData','CData'});
    if~(is_default_xdata&&is_default_ydata)

        hArg=codegen.codeargument('Value',xdata,'Name',xName,'IsParameter',true,...
        'Comment','Surface xdata');
        addConstructorArgin(hCode,hArg);


        hArg=codegen.codeargument('Value',ydata,'Name',yName,'IsParameter',true,...
        'Comment','Surface ydata');
        addConstructorArgin(hCode,hArg);
    end


    hArg=codegen.codeargument('Value',zdata,'Name',zName,'IsParameter',true,...
    'Comment','Surface zdata');
    addConstructorArgin(hCode,hArg);


    if~is_default_cdata

        hArg=codegen.codeargument('Value',cdata,'Name',cName,'IsParameter',true,...
        'Comment','Surface cdata');
        addConstructorArgin(hCode,hArg);
    end

    generateDefaultPropValueSyntax(hCode);
