function undoCS(h,dlg)

    if~strcmp(h.Status,'Converted')
        return;
    end

    try
        h.Status='InProgress';
        h.setDlg(dlg);

        if~bdIsLoaded(h.Name)
            loadFlag=false;
            load_system(h.Name);
        else
            loadFlag=true;
        end

        if h.GUI
            cs=getActiveCS(h.Name);
            chk=checksum(cs,h.Name);
            chk1=checksum(h.PostCS,h.Name);
            if~strcmp(chk,chk1)
                group='restore';
                pref='cs';

                title=DAStudio.message('configset:util:RestoreConfirmation',h.Name);


                description={DAStudio.message('configset:util:RestoreConfirmationDescription1'),...
                DAStudio.message('configset:util:RestoreConfirmationDescription2'),...
                DAStudio.message('configset:util:RestoreConfirmationDescription3')};

                buttons={'b_c','b_s';...
                DAStudio.message('configset:util:OK'),...
                DAStudio.message('configset:util:Cancel')};

                default='b_s';
                a=uigetpref(group,pref,title,description,buttons,'DefautlButton',default);
                if strcmp(a,'b_s')
                    h.Status='Converted';
                    h.setDlg(dlg);
                    return;
                end
            end

            if isa(h.Diff,'DAStudio.Dialog')
                delete(h.Diff);
            end
            try
                delete(h.ErrDlg);
            catch %#ok
            end
        end

        replaceConfigSet(h.Name,h.PreCS);

        if~loadFlag
            try
                w=warning('off','Simulink:Commands:UpgradeToSLXMessage');
                restore_warning=onCleanup(@()warning(w));
                close_system(h.Name,1);
                delete(restore_warning);
            catch e
                close_system(h.Name,0);
                throw(e);
            end
        end

        h.Status='Restored';
        h.Fail=false;

        if h.GUI
            h.setDlg(dlg);
        end
    catch e
        h.Status='Converted';
        h.Fail=true;
        h.ErrMessage=e;
        if h.GUI
            h.setDlg(dlg);
        else
            disp(configset.util.message(e));
        end
    end

