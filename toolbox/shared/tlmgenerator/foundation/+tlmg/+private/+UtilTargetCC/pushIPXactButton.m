function pushIPXactButton(hObj,hDlg,tag)



    if strcmpi(tag,'editIPXactFile')
        propTag=genTag(hObj,'tlmgIPXactPath');
        curValue=hDlg.getWidgetValue(propTag);
        cmd=['edit ',curValue];
        eval(cmd);
        return;
    elseif strcmpi(tag,'browseIPXactFile')
        propTag=genTag(hObj,'tlmgIPXactPath');
        startPath=fullfile(pwd);
        [filename,path]=uigetfile('*.xml','Select IP-XACT file:',startPath);
        hDlg.setWidgetValue(propTag,[path,filename]);
        return;
    end


end
