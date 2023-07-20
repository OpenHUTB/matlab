function writeDisplay2File(con,defaultFilename,varargin)














    fid=optim.internal.problemdef.writeInterfaceHandler(defaultFilename,varargin{:});



    wrapWidth=100;
    printHeaders=true;
    objStr=optim.internal.problemdef.display.showDisplay(con,...
    printHeaders,con.objectType(),wrapWidth);


    objStr=replace(objStr,"\n",newline);
    fprintf(fid,'%s\n',objStr);


    fclose(fid);