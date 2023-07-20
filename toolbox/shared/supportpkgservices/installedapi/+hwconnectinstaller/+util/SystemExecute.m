

classdef(Sealed=true)SystemExecute<handle




    properties(Access=private)
WindowsPipeName
        IsServerLaunched=false
        Debug=false
    end

    methods(Access=private)

        function launchServer(obj,debug)
            server=fullfile(matlabroot,'bin',computer('arch'),'hci_server.exe');

            [~,tpipename,~]=fileparts(tempname);

            if debug
                if system(['"',server,'" ',tpipename,' -d &&exit &'],'-runAsAdmin')
                    error(message('hwconnectinstaller:setup:SystemExecuteServerFail'));
                end
                obj.Debug=true;
                disp('## System Execute Server launched ##');
            else
                if system(['"',server,'" ',tpipename,' &&exit &'],'-runAsAdmin')
                    error(message('hwconnectinstaller:setup:SystemExecuteServerFail'));
                end
                obj.Debug=false;
            end

            obj.WindowsPipeName=tpipename;
            obj.IsServerLaunched=true;
        end

        function result=needLaunchServer(~)
            if~isequal(lower(getenv('SUPPORTPACKAGE_INSTALLER_SYSTEM_EXCUTE')),'off')
                forceLaunchServer=~isempty(getenv('SUPPORTPACKAGE_INSTALLER_EXECSERVER_FORCE'));
                if ispc()&&(forceLaunchServer||~hwconnectinstaller.internal.isAdminMode)
                    result=true;
                else
                    result=false;
                end
            else
                result=false;
            end
        end

        function obj=SystemExecute(debug)
            doDebug=(nargin==1&&debug)||~isempty(getenv('SUPPORTPACKAGE_INSTALLER_EXECSERVER_DEBUG'));
            if obj.needLaunchServer
                if doDebug
                    obj.launchServer(1);
                else
                    obj.launchServer(0);
                end
            end
        end

    end

    methods(Static=true)

        function obj=getInstance(debug)
            persistent localObj;

            if isempty(localObj)||~isvalid(localObj)
                if nargin==1&&isequal(debug,1)
                    localObj=hwconnectinstaller.util.SystemExecute(1);
                else
                    localObj=hwconnectinstaller.util.SystemExecute(0);
                end
            end

            obj=localObj;
        end
    end

    methods(Access=public)


        function[status,msg]=execute(obj,cmd)




            status=0;%#ok<NASGU>
            msg='';

            if(~obj.IsServerLaunched&&obj.needLaunchServer)
                obj.launchServer(obj.Debug);
                if~obj.IsServerLaunched
                    error(message('hwconnectinstaller:setup:SystemExecuteClientFail',cmd));
                end
            end

            if obj.IsServerLaunched
                command=sprintf('%04d%s',length(cmd),cmd);
                try
                    [hciStatus,hciMsg]=hci_client(obj.WindowsPipeName,obj.Debug,command);
                catch
                    error(message('hwconnectinstaller:setup:SystemExecuteClientFail',cmd));
                end

                if(hciStatus==0)
                    status=hciStatus;
                    if exist(hciMsg,'file')==2








                        numReadAttempts=5;
                        try
                            for attempt=1:numReadAttempts,
                                [fileReadable,msg]=readTextFile(hciMsg);
                                if fileReadable,
                                    break;
                                end
                                pause(0.2);
                            end
                        catch
                            error(message('hwconnectinstaller:setup:SystemExecuteClientOutputReadFail',cmd));
                        end

                        if isempty(msg)
                            msg=sprintf('Unable to read output of %s',cmd);
                        else
                            if~isempty(strfind(hciMsg,tempdir))




                                oldWarnState=warning('off','MATLAB:DELETE:Permission');
                                warnCleanup=onCleanup(@()warning(oldWarnState));
                                delete(hciMsg);
                            end
                        end
                    else
                        msg=sprintf('Unable to read output of %s',cmd);
                    end
                else





                    status=1;
                    msg=hciMsg;
                end

            else

                if ispc()&&~hwconnectinstaller.internal.isAdminMode
                    [status,msg]=system(cmd,'-runAsAdmin');
                else
                    [status,msg]=system(cmd);
                end
            end

        end

        function close(obj)
            if obj.IsServerLaunched
                hci_client(obj.WindowsPipeName,obj.Debug,'done');

                obj.IsServerLaunched=false;
                obj.WindowsPipeName='';
            end
        end

        function delete(obj)
            close(obj);
        end

    end

end

function[success,out]=readTextFile(filename)
    fid=fopen(filename,'rt');
    success=(fid>-1);
    if~success,
        out='';
        return;
    end
    cleanup=onCleanup(@()fclose(fid));
    out=fread(fid,'*char')';
end
