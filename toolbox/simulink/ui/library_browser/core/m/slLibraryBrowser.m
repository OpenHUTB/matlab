function varargout=slLibraryBrowser(action)






















    if nargin>0
        action=convertStringsToChars(action);
    end

    nargoutchk(0,1);


    start_simulink;


    mlock;
    persistent lb;

    savedGCS=gcs;
    restore_gcs=onCleanup(@()i_restore_gcs(savedGCS));

    PerfTools.Tracer.logSLStartupData('LibraryBrowser2',true);
    stop_logging=onCleanup(@()...
    PerfTools.Tracer.logSLStartupData('LibraryBrowser2',false));

    if(nargin==0)
        lb=loc_createLibraryBrowser();
        lb.show;
    elseif(nargin==1)
        switch lower(action)
        case 'open',
            lb=loc_createLibraryBrowser();
            lb.show;
        case 'close',
            if isa(lb,'LibraryBrowser.StandaloneBrowser')||isa(lb,'LibraryBrowser.LBStandalone')
                lb.hide();
            else
                error(message('Simulink:LibraryBrowser:lbNotOpen'));
            end
        case 'noshow'
            lb=loc_createLibraryBrowser();
        otherwise,
            error(message('Simulink:LibraryBrowser:invalidArgToSimulink'));
        end
    end
    delete(stop_logging);
    delete(restore_gcs);


    if(nargout>0)
        varargout{1}=lb;
    end

end

function i_restore_gcs(savedGCS)
    if~strcmp(savedGCS,gcs)&&~strcmp(savedGCS,'')
        set_param(0,'CurrentSystem',savedGCS);
    end
end


function lb=loc_createLibraryBrowser()


    if~LibraryBrowser.internal.isLBInitialized()
        msg=message('sl_lib_browse2:sl_lib_browse2:SLLB_StartingLibraryBrowser');
        SLStudio.internal.ScopedStudioBlocker(msg.getString());
        if feature('webui')~=0
            loc_setDesktopStatus(msg.getString());
            restore_status=onCleanup(@()loc_setDesktopStatus(''));
        else

            if usejava('desktop')
                desktopframe=com.mathworks.mlservices.MatlabDesktopServices.getDesktop.getMainFrame;
                javaMethodEDT('setStatusText',desktopframe,msg.getString);
                restore_status=onCleanup(@()javaMethodEDT('setStatusText',desktopframe,[]));
            end

        end
    end


    lb=LibraryBrowser.LibraryBrowser2;
end


function loc_setDesktopStatus(msgString)
    mde=matlab.ui.container.internal.RootApp.getInstance();
    mde.Status=msgString;
end
