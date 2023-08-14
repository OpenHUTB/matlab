function cba_createslcustomization()






    customObj=TflDesigner.tflslcustomization;
    me=TflDesigner.getexplorer;

    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:BusyMsg'));
    anames=me.getaction_names;
    alist='';
    for i=1:length(anames)
        action=me.getaction(anames{i});
        if action.Enabled
            alist{end+1}=anames{i};%#oktogrow
            action.Enabled='off';
        end
    end

    [~]=DAStudio.Dialog(customObj,'sl_customization','DLG_STANDALONE');

    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    for i=1:length(alist)
        me.getaction(alist{i}).Enabled='on';
    end

