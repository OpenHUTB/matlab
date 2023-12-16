function actxinit(interactive)

    persistent initialized

mlock

    if nargin<1
        interactive=false;
    end

    if isempty(initialized)

        disp(getString(message('Slvnv:reqmgt:actx_installed:VerifyingMATLABAutomationServer')));

        warnState=warning('query','backtrace');
        warning('backtrace','off');

        srvPath=get_matlab_autoserver_path();
        if isempty(srvPath)||~strcmpi(srvPath,[matlabroot,'\bin\',computer('arch')])

            if interactive
                fromuser='';
                while isempty(regexp(fromuser,'^\s*[ynYN]\s*$'))%#ok<RGXP1>
                    fromuser=input(getString(message('Slvnv:reqmgt:actx_installed:RegisteringThisMATLABInstallation')),'s');
                end
                goahead=~isempty(regexp(fromuser,'^\s*[yY]\s*$'));%#ok<RGXP1>
            else
                goahead=true;
            end

            if goahead
                disp(getString(message('Slvnv:reqmgt:actx_installed:RegisteringThisMATLABExecutable')));
                try
                    regmatlabserver('runAsAdmin');
                catch Mex
                    warning(Mex.identifier,'%s',Mex.message);
                end
            end
        end

        try
            enableservice('AutomationServer',true);
            initialized=true;

        catch Mex
            initialized=false;
        end

        if~initialized
            if(strcmp(Mex.identifier,'MATLAB:COM:InvalidProgid'))
                disp(getString(message('Slvnv:reqmgt:actx_installed:UnableStartMATLABAutomation')));
                disp(getString(message('Slvnv:reqmgt:actx_installed:WillNotNavigate')));
                disp(getString(message('Slvnv:reqmgt:actx_installed:ManuallyRegisterServer')));
            end
        end
        warning(warnState);
    end



    function myPath=get_matlab_autoserver_path
        myPath='';
        try
            clsid=winqueryreg('HKEY_CLASSES_ROOT','matlab.autoserver\CLSID');
        catch Mex %#ok<NASGU>
            clsid='';
        end

        if~isempty(clsid)
            try
                serverRegPath=['CLSID\',clsid,'\LocalServer32'];
                myPath=winqueryreg('HKEY_CLASSES_ROOT',serverRegPath);
                exeStart=regexpi(myPath,'matlab\.exe');
                if~isempty(exeStart)
                    myPath=myPath(1:(exeStart(1)-2));
                end
            catch Mex %#ok<NASGU>
                myPath='';
            end
        end




