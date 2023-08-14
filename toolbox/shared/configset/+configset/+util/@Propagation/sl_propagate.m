function sl_propagate(h)

    h.Dirty=true;
    h.Mode=1;
    h.setDlg();

    vs=h.Map.values;
    for i=h.Index:length(vs)
        pause(0.1);
        if h.Mode>2
            if h.Mode==5
                h.Time=datestr(clock);
                h.stopProcess();
            else
                h.Index=i;
                h.setDlg();
            end

            if h.Mode==3
                pause_id=h.Index-1;
                pause_mdls=h.Map.values;
                pause_mdl=pause_mdls{pause_id};
                pause_name=pause_mdl.Name;
                if isa(h.Dialog,'DAStudio.Dialog')
                    h.Dialog.setWidgetValue('BackupInfo',h.setBackupStr(pause_name,pause_id));
                end
            end
            return;
        end

        v=vs{i};
        if h.GUI&&isa(h.Dialog,'DAStudio.Dialog')
            h.Dialog.setWidgetValue('BackupInfo',h.setBackupStr(v.Name,i));
        end

        v.setCS(h.CS,h.Dialog);

        if~h.IsPropagated
            if strcmp(v.Status,'Converted')
                h.IsPropagated=true;
            end
        end


        h.setDlg();
    end

    h.Mode=0;
    h.Index=1;
    if h.IsPropagated
        h.Time=datestr(clock);
    end
    h.setDlg();
    h.save();
