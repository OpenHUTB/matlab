function[outdata,warnStr,datasourceMetrics,errMsg]=cb_Refresh(State)




    errMsg='';


    try
        Simulink.io.FileTypeFactory.getInstance().updateFactoryRegistry();
        aFileObj=Simulink.io.FileTypeFactory.getInstance().createReader(State.matFile,State.readerName);
        [outdata,warnStr,datasourceMetrics]=slwebwidgets.customfile.getMetaDataFromFile(aFileObj);
    catch ME
        outdata=[];
        warnStr=[];
        datasourceMetrics=[];
        errMsg=ME.message;
    end
