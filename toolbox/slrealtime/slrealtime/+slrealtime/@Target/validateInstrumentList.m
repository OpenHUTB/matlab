function validateInstrumentList(this)







    appName=this.tc.ModelProperties.Application;

    if isempty(this.instrumentList)
        this.streamingAcquireList=[];
        this.instrumentList=[];
        this.mapStreamingALToInstList=[];
        this.streamingAcquireListRefrenceCount=[];
    else

        oldInstList=this.instrumentList;
        invalidFlag=false;

        for iHI=1:length(oldInstList)
            hInst=oldInstList(iHI);







            needsToBeValidated=true;
            if~isempty(hInst.Application)



                appName=this.tc.ModelProperties.Application;
                hostUUID=hInst.Checksum;
                targetUUID=this.getUUIDFromTarget(appName);

                if strcmp(hostUUID,targetUUID)



                    needsToBeValidated=false;
                end
            end
            if needsToBeValidated
                invalidFlag=true;
                hInst.validate(this.getAppFile(appName));
            end



            hInst.registerObserversWithTarget(this);

        end

        if invalidFlag||isempty(this.streamingAcquireList)||this.forceRefresh
            this.refreshInstrumentList(true);
            this.forceRefresh=false;
        end
    end
end
