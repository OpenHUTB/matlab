function writeTableStrToFile(tableStr,fileName)
    import slreq.report.internal.rtmx.*
    fid=fopen(fileName,'w+');
    styleStr=createTableStyle;
    scriptStr=createTableScripts;

    headerStr=createCellStr('head',styleStr);

    preTableStr=createTableFunctionStr();
    bodyContent=[preTableStr,tableStr];

    bodyStr=createCellStr('body',[bodyContent,scriptStr]);
    htmlStr=createCellStr('html',[headerStr,newline,bodyStr]);

    fprintf(fid,'%s\n',htmlStr);
    fclose(fid);
end