function rtw_disp_info(iMdl,iSummary,iMsg)













    OkayToPushNag=rtwprivate('rtwattic','getOkayToPushNag');

    if OkayToPushNag
        Simulink.output.info(iMsg,'Component','RTW','Category','Build');


        disp(iMsg);
    else
        disp(iMsg);
    end

