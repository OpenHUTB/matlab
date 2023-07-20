


function Result=WarningCount


    Result=0;


    LogFileName=IMTPrivate('IMTGlobalSetting','LogFile');


    if exist(LogFileName,'file')


        fid=fopen(LogFileName);


        while~feof(fid)
            LogLine=fgetl(fid);
            if strncmp(LogLine,'Warning: ',9)
                Result=Result+1;
            end;
        end;

        fclose(fid);

    end;
