function files=getCrashStack(tg)








    files=[];

    if ischar(tg)||isstring(tg)
        targetName=tg;
        tg=slrealtime(targetName);
    end




    if~exist('crashdumptemp')
        mkdir('crashdumptemp');
    end
    cd('crashdumptemp');
    stacktraces=slrealtime.internal.gdb.stackTrace(tg);
    cd('..');

    for ii=1:length(stacktraces)
        stacktrace=stacktraces(ii);
        filename=sprintf("%s-crashstack.txt",stacktrace.name);
        [filehandle,errmsg]=fopen(filename,"w");
        if filehandle==-1
            slrealtime.internal.throw.Error('slrealtime:target:updateFileOpenError',filename,errmsg);
        end

        fwrite(filehandle,stacktrace.stack);
        fclose(filehandle);
        edit(filename);
        files=[files;filename];%#ok<AGROW>
    end

end