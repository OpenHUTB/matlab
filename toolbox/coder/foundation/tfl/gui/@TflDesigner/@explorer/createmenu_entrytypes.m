function m=createmenu_entrytypes(h)




    am=DAStudio.ActionManager;
    m=am.createPopupMenu(h);


    action=h.getaction('FILE_NEW_ENTRY_TFLCOP');
    m.addMenuItem(action);

    action=h.getaction('FILE_NEW_ENTRY_TFLCFUNC');
    m.addMenuItem(action);

    action=h.getaction('FILE_NEW_ENTRY_TFLBLAS');
    m.addMenuItem(action);

    action=h.getaction('FILE_NEW_ENTRY_TFLCBLAS');
    m.addMenuItem(action);

    action=h.getaction('FILE_NEW_ENTRY_TFLCOPGENNET');
    m.addMenuItem(action);

    action=h.getaction('FILE_NEW_ENTRY_TFLCOPSEM');
    m.addMenuItem(action);

    if feature('CrtoolShowCustomization')>0
        action=h.getaction('FILE_NEW_ENTRY_TFLCUSTOMIZATION');
        m.addMenuItem(action);
    end

    m.addSeparator;


    customaction=h.getcustomtypes;

    if~isempty(customaction)
        for i=1:length(customaction)
            m.addMenuItem(customaction{i});
        end
        m.addSeparator;
    end



