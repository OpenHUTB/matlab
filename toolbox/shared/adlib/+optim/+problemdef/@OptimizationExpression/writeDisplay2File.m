function writeDisplay2File(expr,defaultFilename,varargin)













    fid=optim.internal.problemdef.writeInterfaceHandler(defaultFilename,varargin{:});



    wrapWidth=100;
    printHeaders=true;
    objStr=optim.internal.problemdef.display.showDisplay(expr,...
    printHeaders,'expression',wrapWidth);


    objStr=replace(objStr,"\n",newline);
    fprintf(fid,'%s\n',objStr);


    fclose(fid);