function configure(uname)

    persistent testURL

    if nargin>0&&isempty(uname)



        if isempty(testURL)
            testURL=testConnectionFromBrowser();
        end
        return;
    end

    fprintf(1,'%s ',getString(message('Slvnv:oslc:ConfigServerAddress')));
    serverUrl=oslc.server();
    if isempty(serverUrl)

        fprintf(1,' %s\n\n',getString(message('Slvnv:rmiref:Check:writeReport:s_ActionCanceled')));
        return;
    end
    rmipref('OslcServerAddress',serverUrl);
    fprintf(1,' %s\n',getString(message('Slvnv:oslc:ConfigValueSet',serverUrl)));

    fprintf(1,'%s ',getString(message('Slvnv:oslc:ConfigServerLogin')));
    if nargin<1
        try
            uname=oslc.user();
        catch ex
            if strcmp(ex.identifier,'Slvnv:oslc:UserNameNotEntered')
                uname='';
            else
                throwAsCaller(ex);
            end
        end
        if isempty(uname)

            fprintf(1,' %s\n\n',getString(message('Slvnv:rmiref:Check:writeReport:s_ActionCanceled')));
            return;
        end
    else
        oslc.user(uname);
    end
    fprintf(1,' %s\n',getString(message('Slvnv:oslc:ConfigValueSet',uname)));

    if isempty(testURL)


        fprintf(1,' %s',getString(message('Slvnv:oslc:ConfigDestinationType')));
        ltype=rmi.linktype_mgr('resolveByRegName','linktype_rmi_oslc');
        if isempty(ltype)
            oslc.registerDomain();
            fprintf(1,' %s\n',getString(message('Slvnv:oslc:ConfigOslcRegistered')));
        else
            rmipref('SelectionLinkDoors',true);
            fprintf(1,' %s\n',getString(message('Slvnv:oslc:ConfigOslcWasRegistered')));
        end

        fprintf(1,' %s',getString(message('Slvnv:oslc:ConfigMatlabListening')));
        if slreq.connector.Oslc.register()
            fprintf(1,' %s\n',getString(message('Slvnv:oslc:ConfigMatlabStarted')));
        else
            fprintf(1,' %s\n',getString(message('Slvnv:oslc:ConfigMatlabRunning')));
        end
    end


    fprintf(1,'%s\n',getString(message('Slvnv:oslc:EnterPassword')));
    if isempty(oslc.connection())
        return;
    end



    fprintf(1,'%s\n',getString(message('Slvnv:oslc:SpecifyProjectConfig')));
    oslc.Project.currentProject('','');
    projSelector=oslc.DlgSelectProject();
    projSelector.doTestBrowser=true;
    try

        DAStudio.Dialog(projSelector);
    catch ex
        rmiut.warnNoBacktrace(ex.message);
    end
end

function testURL=testConnectionFromBrowser()
    rmiut.progressBarFcn('set',0.9,getString(message('Slvnv:oslc:TestingSystemBrowser')));
    testURL=oslc.getConnectorTestURL();
    web(testURL,'-browser');
    fprintf(1,'%s\n\t%s\n\t%s\n\t%s\n',...
    getString(message('Slvnv:oslc:ConfigBrowserTestLine1')),...
    getString(message('Slvnv:oslc:ConfigBrowserTestLine2')),...
    getString(message('Slvnv:oslc:ConfigBrowserTestLine3')),...
    testURL);
    rmiut.progressBarFcn('delete');
end
