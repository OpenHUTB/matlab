function writeDisplay2File(prob,defaultFilename,varargin)













    fid=optim.internal.problemdef.writeInterfaceHandler(defaultFilename,varargin{:});



    wrapWidth=100;
    addBolding=false;
    fprintf(fid,'%s\n',expand2str(prob,addBolding,wrapWidth));


    fclose(fid);
