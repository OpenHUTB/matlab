function SignalAnalyzerHelp(helpType)

    mapRoot=fullfile(docroot,'/signal/','signal.map');

    switch helpType
    case 'sigAppHelp'
        helpview(mapRoot,'signal_app');
    case 'editTimeDlgHelp'
        helpview(mapRoot,'signal_app_edit_time');
    case 'aboutSPT'
aboutsignaltbx
    case 'exportDlg'
        helpview(mapRoot,'signal_app_export');
    case 'preprocessingSAHelp'
        helpview(mapRoot,'signal_app_preprocessingMode');
    case 'preprocessingSAHelp_smooth'
        helpview(mapRoot,'signal_app_preprocessingMode_smooth');
    case{'preprocessingSAHelp_lowpassfilter','preprocessingSAHelp_highpassfilter',...
        'preprocessingSAHelp_bandpassfilter','preprocessingSAHelp_bandstopfilter'}
        helpview(mapRoot,'signal_app_preprocessingMode_filter');
    case 'preprocessingSAHelp_resample'
        helpview(mapRoot,'signal_app_preprocessingMode_resample');
    case 'preprocessingSAHelp_detrend'
        helpview(mapRoot,'signal_app_preprocessingMode_detrend');
    case 'preprocessingSAHelp_envelope'
        helpview(mapRoot,'signal_app_preprocessingMode_envelope');
    case 'preprocessingSAHelp_denoise'
        helpview(mapRoot,'signal_app_preprocessingMode_denoise');
    case 'preprocessingSAHelp_custom'
        helpview(mapRoot,'signal_app_preprocessingMode_custom');
    otherwise
        helpview(mapRoot,'signal_app');
    end
end
