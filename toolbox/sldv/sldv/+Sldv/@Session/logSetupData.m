function logSetupData(obj)




    if~(slavteng('feature','LogSLDVDDUX'))

        return;
    end


    eventKey="DV_ANALYSIS_SETUP";
    data.client=obj.mClient.char;
    data.mode=obj.mSldvOpts.Mode;


    sldv.ddux.Logger.getInstance().logData(eventKey,data);

end


