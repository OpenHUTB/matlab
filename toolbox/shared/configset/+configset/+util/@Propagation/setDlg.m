function setDlg(h)



    if~h.GUI||~isa(h.Dialog,'DAStudio.Dialog')
        return;
    end

    dlg=h.Dialog;
    name=dlg.getWidgetValue('searchInput');
    vs=h.Map.values;
    sl=0;
    c=0;
    r=0;
    s=0;
    f=0;
    for i=1:h.Number
        v=vs{i};
        sl=sl+v.IsSelected;
        k=regexpi(v.Name,name);
        found=isempty(name)||~isempty(k);

        switch v.Status
        case 'Converted'
            c=c+1;
            dlg.setVisible(strcat('a_',v.Name),h.IsConvertedChecked&&found);
        case 'Skipped'
            s=s+1;
            dlg.setVisible(strcat('a_',v.Name),h.IsSkippedChecked&&found);
        case 'Restored'
            r=r+1;
            dlg.setVisible(strcat('a_',v.Name),h.IsRestoredChecked&&found);
        case 'Failed'
            f=f+1;
            dlg.setVisible(strcat('a_',v.Name),h.IsFailedChecked&&found);
        otherwise
            dlg.setVisible(strcat('a_',v.Name),found);
        end

        if v.Fail
            f=f+1;
            dlg.setVisible(strcat('a_',v.Name),h.IsFailedChecked&&found);
        end
    end

    dlg.setWidgetPrompt('Converted',[DAStudio.message('configset:util:Status_Converted'),': ',num2str(c),'  ']);
    dlg.setWidgetPrompt('Restored',[DAStudio.message('configset:util:Status_Restored'),': ',num2str(r),'  ']);
    dlg.setWidgetPrompt('Skipped',[DAStudio.message('configset:util:Status_Skipped'),': ',num2str(s),'  ']);
    dlg.setWidgetPrompt('Failed',[DAStudio.message('configset:util:Status_Failed'),': ',num2str(f),'  ']);

    dlg.setWidgetValue('Converted',h.IsConvertedChecked);
    dlg.setWidgetValue('Restored',h.IsRestoredChecked);
    dlg.setWidgetValue('Skipped',h.IsSkippedChecked);
    dlg.setWidgetValue('Failed',h.IsFailedChecked);



    if~h.Mode
        dlg.setWidgetValue('BackupInfo',h.setBackupStr());
    end

    dlg.setEnabled('pauseButton',h.Mode==1||h.Mode==2);

    dlg.setEnabled('PB',sl>0&&(h.Mode~=1&&h.Mode~=2));
    dlg.setEnabled('RB',c>0&&(h.Mode~=1&&h.Mode~=2));
    dlg.setWidgetValue('Model',DAStudio.message('configset:util:TopPan_Model',sl,h.Number));

    if sl==0
        dlg.setVisible('checkoff',true);
        dlg.setVisible('checkon',false);
        dlg.setVisible('checktri',false);
    elseif sl>0&&sl<h.Number
        dlg.setVisible('checktri',true);
        dlg.setVisible('checkon',false);
        dlg.setVisible('checkoff',false);
    elseif sl==h.Number
        dlg.setVisible('checkon',true);
        dlg.setVisible('checkoff',false);
        dlg.setVisible('checktri',false);
    end

