function out=connection(varargin)



    persistent myConnection

    if nargin>0
        if isempty(varargin{1})


            if~isempty(myConnection)
                delete(myConnection);
            end
            myConnection=[];
            if nargout==0
                return;
            end
        elseif isa(varargin{1},'oslc.matlab.DngClient')


            myConnection=varargin{1};
            return;
        end
    end

    if isempty(myConnection)||~isOperational(myConnection)

        serverAddress=oslc.server();
        if isempty(serverAddress)

            out=[];
            return;
        end

        serverUser=oslc.user();
        if isempty(serverUser)

            out=[];
            return;
        end


        usingProgressBar=rmiut.progressBarFcn('exists');
        if usingProgressBar
            rmiut.progressBarFcn('set',0.2,getString(message('Slvnv:oslc:TryAuthenticatedConnection',serverUser)));
            cln=onCleanup(@()rmiut.progressBarFcn('delete'));
        end
        maxRetry=3;
        retry=0;
        myConnection=[];
        while isempty(myConnection)&&retry<maxRetry
            if usingProgressBar
                rmiut.progressBarFcn('set',1.0-retry*0.2,getString(message('Slvnv:oslc:TryAuthenticatedConnection',serverUser)));
            end

            try

                myConnection=oslc.matlab.DngClient.getInstance();
                break;
            catch ex
                rmiut.warnNoBacktrace(ex.message);
                myConnection=[];
                oslc.passcode([]);
                retry=retry+1;
            end
        end



        if isempty(myConnection)
            reply=questdlg(...
            getString(message('Slvnv:oslc:FailedLoginMessage')),...
            getString(message('Slvnv:oslc:FailedLogin')),...
            getString(message('Slvnv:oslc:AdjustURL')),...
            getString(message('Slvnv:oslc:AdjustUsername')),...
            getString(message('Slvnv:oslc:Cancel')),...
            getString(message('Slvnv:oslc:AdjustUsername')));
            if isempty(reply)

            else
                switch reply
                case getString(message('Slvnv:oslc:AdjustURL'))
                    oslc.server([]);
                    myConnection=oslc.connection();
                case getString(message('Slvnv:oslc:AdjustUsername'))
                    oslc.user([]);
                    myConnection=oslc.connection();
                case getString(message('Slvnv:oslc:Cancel'))

                otherwise
                    error('Unexpected CASE in failed login prompt response');
                end
            end
        end
    end

    out=myConnection;
end

function success=isOperational(connection)




    persistent lastCheckTime
    if isempty(lastCheckTime)
        lastCheckTime=0;
    end
    nowTime=now;
    if nowTime-lastCheckTime<0.007
        success=true;
        return;
    end

    try
        userQueryURL=sprintf('%s/jts/whoami',oslc.server());
        result=char(connection.get(userQueryURL));
        if endsWith(strtrim(result),oslc.user())
            success=true;
            lastCheckTime=nowTime;
        else
            error(result);
        end
    catch ex

        rmiut.warnNoBacktrace(ex.message);
        success=false;
    end
end

