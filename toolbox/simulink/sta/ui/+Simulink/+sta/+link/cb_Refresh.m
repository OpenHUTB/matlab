function[outdata,warnStr,datasourceMetrics,errStr]=cb_Refresh(State)



    errStr='';
    if strcmpi(State.importFrom,'imMatFile')&&exist(State.matFile,'file')==0
        outdata=[];
        warnStr=[];
        datasourceMetrics=[];
        errStr=DAStudio.message('sl_web_widgets:linkimportdialogs:matfileExistError');
        return;
    end

    [outdata,warnStr,datasourceMetrics]=Simulink.sta.importdialog.cb_Refresh(State);

end

