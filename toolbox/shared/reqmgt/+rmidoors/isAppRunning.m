function result=isAppRunning(message_type)



    if nargin>0
        message_type=convertStringsToChars(message_type);
    end

    if nargin==0||isempty(message_type)
        message_type='default';
    end

    result=0;
    try
        result=reqmgt('findProc','doors.exe');
        if strcmp(message_type,'nodialog')
            return
        end

        while result~=1

            if strcmp(message_type,'default')
                ButtonName=questdlg(getString(message('Slvnv:reqmgt:is_doors_running:DOORSIsNotRunning')),...
                'Warning','OK','Retry','OK');
                if isempty(ButtonName)
                    ButtonName='OK';
                end

            elseif strcmp(message_type,'consistency check')
                ButtonName=questdlg({getString(message('Slvnv:reqmgt:is_doors_running:DOORSIsNotRunning')),...
                '',...
                getString(message('Slvnv:reqmgt:is_doors_running:IfYouClickContinue'))},...
                getString(message('Slvnv:reqmgt:is_doors_running:DOORSUnavailable')),...
                'Retry','Continue','Cancel','Retry');
                if isempty(ButtonName)
                    ButtonName='Retry';
                end

            elseif strcmp(message_type,'RMI report')
                ButtonName=questdlg({getString(message('Slvnv:reqmgt:is_doors_running:DOORSIsNotRunning')),...
                '',...
                getString(message('Slvnv:reqmgt:is_doors_running:IfYouClickSkip'))},...
                getString(message('Slvnv:reqmgt:is_doors_running:DOORSUnavailable')),...
                'Retry','Skip','Retry');
                if isempty(ButtonName)
                    ButtonName='Retry';
                end

            elseif strcmp(message_type,'synchronization')
                ButtonName=questdlg(...
                getString(message('Slvnv:reqmgt:is_doors_running:DOORSClientMustBeConnected')),...
                getString(message('Slvnv:reqmgt:is_doors_running:DOORSUnavailable')),...
                'Retry','Cancel','Retry');
                if isempty(ButtonName)
                    ButtonName='Retry';
                end
            end

            switch ButtonName
            case 'Continue'
                result=1;
                return;
            case 'Cancel'
                return;
            case 'Skip'
                return;
            case 'OK'
                break;
            case 'Retry'
                result=reqmgt('findProc','doors.exe');
            end
        end

        if result==1
            hDoors=rmidoors.comApp();
            if isempty(hDoors)
                title=getString(message('Slvnv:reqmgt:is_doors_running:FailedToCommunicateWithDOORS'));
                msg=getString(message('Slvnv:reqmgt:is_doors_running:FailedToCommunicateWithDOORS_content'));
                errordlg(msg,title);
                result=0;
            end
        end

    catch Mex
        disp(Mex.message);
    end
end
