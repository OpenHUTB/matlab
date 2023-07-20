function mcodeConstructor(this,hCode)




    setConstructorName(hCode,'boxchart')
    plotutils('makemcode',this,hCode)


    ignoreProperty(hCode,{'XData'});
    if strcmp(this.XDataMode,'manual')
        arg=codegen.codeargument('Name','xgroupdata','Value',this.XData...
        ,'IsParameter',true);
        addConstructorArgin(hCode,arg);
    end


    ignoreProperty(hCode,{'YData'});
    arg=codegen.codeargument('Name','ydata','Value',this.YData,'IsParameter',true);
    addConstructorArgin(hCode,arg);


    generateDefaultPropValueSyntax(hCode);
