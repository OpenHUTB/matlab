function mcodeConstructor(this,code)




    setConstructorName(code,'plot');

    plotutils('makemcode',this,code);


    ignoreProperty(code,'XData');
    ignoreProperty(code,'XDataMode');
    arg=codegen.codeargument('Name','X','Value',this.XData,...
    'IsParameter',true,...
    'Comment',getString(message('MATLAB:specgraph:mcodeConstructor:CommentVectorData','x')));
    addConstructorArgin(code,arg);

    ignoreProperty(code,'YData');
    ignoreProperty(code,'YDataMode');
    arg=codegen.codeargument('Name','Y','Value',this.YData,...
    'IsParameter',true,...
    'Comment',getString(message('MATLAB:specgraph:mcodeConstructor:CommentVectorData','y')));
    addConstructorArgin(code,arg);


    generateDefaultPropValueSyntax(code);
