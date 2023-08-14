function SigappsHelp(helpType)

    mapRoot=fullfile(docroot,'/signal/','signal.map');

    switch helpType
    case 'editTimeDlgHelp'
        helpview(mapRoot,'signal_app_edit_time');
    end
end
