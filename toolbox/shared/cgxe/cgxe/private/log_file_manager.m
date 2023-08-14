function result=log_file_manager(cmd,targetId,varargin)




    persistent sLogFileInfo

    if(isempty(sLogFileInfo))
        sLogFileInfo.logFileName='';
        sLogFileInfo.memoryMode=0;
        sLogFileInfo.logText='';
        mlock;
    end

    result='';
    switch(cmd),
    case 'memory_mode'
        if(nargin>1)
            sLogFileInfo.memoryMode=targetId;
        end
        result=sLogFileInfo.memoryMode;
        return;
    case 'begin_log',sLogFileInfo=begin_log_l(sLogFileInfo);
    case 'end_log',sLogFileInfo=end_log_l(sLogFileInfo);
    case 'get_log',result=get_log_l(sLogFileInfo);
    case 'get_active_log_name',result=sLogFileInfo.logFileName;
    case 'add_log',sLogFileInfo=add_log_l(sLogFileInfo,varargin{1});
    case 'dump_log',dump_log(varargin{:});
    otherwise,warning('Stateflow:UnexpectedError',DAStudio.message('Stateflow:sfprivate:warning_BadParameterPassedToLog_file_manager'));
    end


    function logFileInfo=begin_log_l(logFileInfo)



        if(logFileInfo.memoryMode==0)
            if isempty(logFileInfo.logFileName)||exist(logFileInfo.logFileName,'file')~=2,
                logFileInfo.logFileName=tempname;
            end
            fp=fopen(logFileInfo.logFileName,'w');
            if(fp==-1)
                logFileInfo.logFileName='';
                logFileInfo.memoryMode=1;
                logFileInfo.logText='';
            else
                logFileInfo.memoryMode=0;
                fclose(fp);
            end
        else
            logFileInfo.logFileName='';
            logFileInfo.memoryMode=1;
            logFileInfo.logText='';
        end


        function logFileInfo=add_log_l(logFileInfo,msgString)



            if(logFileInfo.memoryMode==0&&~isempty(logFileInfo.logFileName))
                fp=fopen(logFileInfo.logFileName,'a');
                if(fp~=-1)
                    fprintf(fp,'%s\n',msgString);
                    fclose(fp);
                else


                    logFileInfo.logText=get_log_l(logFileInfo);
                    logFileInfo=end_log_l(logFileInfo);
                    logFileInfo.memoryMode=1;
                    logFileInfo.logText=[logFileInfo.logText,msgString,10];
                end
            else
                logFileInfo.logText=[logFileInfo.logText,msgString,10];
            end



            function logFileInfo=end_log_l(logFileInfo)




                if(logFileInfo.memoryMode==0)
                    if~isempty(logFileInfo.logFileName),
                        try
                            cgxe_delete_file(logFileInfo.logFileName);
                        catch
                        end;
                    end;
                    logFileInfo.logFileName='';
                else
                    logFileInfo.logText='';
                end



                function msg=get_log_l(logFileInfo)



                    msg='';
                    if(logFileInfo.memoryMode==0&&~isempty(logFileInfo.logFileName))
                        fid=fopen(logFileInfo.logFileName,'rt');
                        if(fid<=2)
                            msg='';
                            return;
                        end;
                        msg=fread(fid,'*char')';
                        fclose(fid);
                    else
                        msg=logFileInfo.logText;
                    end

                    function dump_log(modelName,errorOccurred)

                        logTxt=log_file_manager('get_log');
                        if~isempty(logTxt)
                            fprintf('%s\n',DAStudio.message('Simulink:cgxe:BuildStartConsoleMessage',modelName));
                            fprintf('%s\n',logTxt);
                            if(errorOccurred)
                                fprintf('%s\n',...
                                DAStudio.message('Simulink:cgxe:BuildErrorConsoleMessage',modelName));
                            else
                                fprintf('%s\n',...
                                DAStudio.message('Simulink:cgxe:BuildSuccessConsoleMessage',modelName));
                            end
                        end


