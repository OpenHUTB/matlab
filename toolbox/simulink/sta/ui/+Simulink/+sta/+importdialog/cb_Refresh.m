function[outdata,warnStr,datasourceMetrics]=cb_Refresh(State)




    outdata=[];
    warnStr=[];
    datasourceMetrics.SLDVVarNames=[];
    datasourceMetrics.SLDVTransformedNames=[];

    if(isequal(State.importFrom,'imMatFile')&&~isempty(State.matFile))
        aFileObj=iofile.STAMatFile(State.matFile);
        [outdata,warnStr,datasourceMetrics]=Simulink.sta.importdialog.getMetaDataFromMatFile(aFileObj);
    elseif(isequal(State.importFrom,'imBaseWorkspace'))
        aFileObj=iofile.BaseWorkspace();
        [outdata,warnStr,datasourceMetrics]=Simulink.sta.importdialog.getMetaDataFromMatFile(aFileObj);
    else

    end

end