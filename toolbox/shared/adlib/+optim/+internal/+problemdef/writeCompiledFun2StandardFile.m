function hdl=writeCompiledFun2StandardFile(fcnname,filebody,filepath)









    sPath=what(filepath);


    filename=fullfile(sPath.path,sprintf('%s.m',fcnname));




    if isfile(filename)
        delete(filename);
    end


    fileID=fopen(filename,'w');

    if fileID==-1
        throwAsCaller(MException(message('shared_adlib:writeInterfaceHandler:FileOpenError',filename)));
    end

    closeFile=onCleanup(@()fclose(fileID));


    fprintf(fileID,'%s',filebody);


    hdl=builtin('_GetFunctionHandleForFullpath',char(filename));