function tlmgenerator_launchreport

    try

        SystemInfo=tlmgenerator_getcodeinfo();
        cfg=tlmgenerator_getconfigset(SystemInfo.Name);

        if(strcmp(cfg.GenerateReport,'on'))
            savedWarn=warning('query','MATLAB:MKDIR:DirectoryExists');
            warning('off','MATLAB:MKDIR:DirectoryExists');

            mkdir(fullfile('..',cfg.tlmgDocOutDir));
            mkdir(fullfile('..',cfg.tlmgDocHtmlDir));

            copyfile(fullfile('html','*.html'),fullfile('..',cfg.tlmgDocHtmlDir),'f');

            warning(savedWarn);

            LaunchReportPrev=getappdata(0,'tlmgLaunchReportPrev');
            unlock(getActiveConfigSet(SystemInfo.Name));
            set_param(SystemInfo.Name,'LaunchReport',LaunchReportPrev);
            lock(getActiveConfigSet(SystemInfo.Name));

            if(strcmp(get_param(SystemInfo.Name,'LaunchReport'),'on'))

                prev_pwd=pwd();
                cd('..');
                rptFile=dir(fullfile(pwd(),cfg.tlmgDocHtmlDir,'*_rpt.html'));
                rptFileName=fullfile(pwd(),cfg.tlmgDocHtmlDir,rptFile.name);
                cd(prev_pwd);

                dasRoot=DAStudio.Root;
                if dasRoot.hasWebBrowser
                    coder.internal.showHtml(rptFileName,'UseWebBrowserWidget');
                else
                    coder.internal.showHtml(rptFileName);
                end

            end

        end

    catch ME
        l_me=MException('TLMGenerator:build','TLMG launchreport: %s',ME.message);
        throw(l_me);
    end

end

