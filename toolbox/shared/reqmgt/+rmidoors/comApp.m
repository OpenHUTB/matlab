function out=comApp(method,varargin)





    persistent hDOORS;

    out=[];


    if rmisync.syncTestMode()
        return;
    end


    if isempty(hDOORS)
        hDOORS=initServer();

    elseif nargin==1&&strcmp(method,'get')


    elseif isServerValid(hDOORS)


    else

        hDOORS=initServer();
    end


    if isempty(hDOORS)
        out=[];

    elseif nargin==0||strcmp(method,'get')
        out=hDOORS;

    else
        switch method

        case 'dispapp'

            if ispc()
                reqmgt('winFocus','.*DOORS Database');
            end

        case 'dispdoc'
            cmdStr=['edit("',varargin{1},'")'];
            try
                rmidoors.invoke(hDOORS,cmdStr);
            catch Mex %#ok<NASGU>
                disp(['Problems loading "',varargin{1},'"']);
            end

            if ispc()
                reqmgt('winFocus',[varargin{1},'.*']);
            end

        otherwise
            error(message('Slvnv:reqmgt:com_doors_app:UnknownMethod'));
        end

    end
end



function server=initServer()
    try
        server=actxserver('DOORS.Application');
        if~apiVersionCheck(server)
            server=[];
        end
    catch Mex %#ok<NASGU>
        server=[];
    end
end

function result=isServerValid(hDOORS)

    result=1;
    try
        rmidoors.invoke(hDOORS,'');
    catch Mex %#ok<NASGU>
        result=0;
    end
end

function status=apiVersionCheck(hDOORS)


    expectedVer='R2021b';

    status=0;


    try
        rmidoors.invoke(hDOORS,'dmiVersionNumber();');
        verStr=hDOORS.result;
    catch Mex %#ok<NASGU>

        errordlg({getString(message('Slvnv:reqmgt:com_doors_app:DoorsCommunicationFailed')),...
        ' ',...
        getString(message('Slvnv:reqmgt:com_doors_app:IfYouSeeLoginDlg'))},...
        getString(message('Slvnv:reqmgt:com_doors_app:DoorsApiError')));


        return;
    end
    actualVer=sscanf(verStr,'Interface version %s');
    if isempty(actualVer)

        errordlg({...
        getString(message('Slvnv:reqmgt:com_doors_app:FailedToVerifyVersion')),...
        ' ',...
        getString(message('Slvnv:reqmgt:com_doors_app:TerminateAndRestart'))},...
        getString(message('Slvnv:reqmgt:com_doors_app:DoorsApiError')));


        return;
    end


    try
        expected=versionStrToNum(expectedVer);
        actual=versionStrToNum(actualVer);
        if actual>=expected
            status=1;
        else
            status=0;
        end
    catch Mex
        warning(message('Slvnv:reqmgt:com_doors_app:versionCheckError',actualVer,expectedVer,Mex.message));
        status=0;
    end

    if~status


        if strcmp(actualVer,'3.19')


            actualVer=[actualVer,' (R2014b)'];
        elseif length(actualVer)>4

            actualVer=['R',actualVer(1:4),char(96+str2num(actualVer(6)))];%#ok<ST2NM>
        end

        choice=questdlg(...
        getString(message('Slvnv:reqmgt:com_doors_app:MatlabDoorsInconsistentVersion',expectedVer,actualVer)),...
        getString(message('Slvnv:reqmgt:com_doors_app:VersionInconsistency')),...
        'Install','Abort','Install');
        if isempty(choice)
            choice='Abort';
        end
        if strcmp(choice,'Install')
            rmidoors.setup();
            error(message('Slvnv:reqmgt:com_doors_app:DoorsRestartRequired'));
        end
    end
end

function versionNumber=versionStrToNum(versionString)
    if versionString(1)=='R'


        versionNumber=str2double(versionString(2:5))+((versionString(6)-'a')+1)/10;
    else
        versionNumber=str2double(versionString);
    end
end
