function txt=showLogFile








    t=xmlcomp.internal.tempdirManager;
    currentLogFile=fullfile(t.getCurrentTempdir,'log.txt');
    if exist(currentLogFile,'file')
        if nargout<1
            edit(currentLogFile);
        else
            f=fopen(currentLogFile);
            txt=textscan(f,'%s','delimiter',sprintf('\n'));
            fclose(f);
            if iscell(txt)
                txt=txt{:};
            end
        end
    else
        key='engine:NoLogFile';
        message=xmlcomp.internal.message(key,currentLogFile);
        warning(['XMLComparison:',key],'%s',message);
    end
