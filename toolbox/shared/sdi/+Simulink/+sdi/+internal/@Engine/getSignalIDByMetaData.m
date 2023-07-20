function signalID=getSignalIDByMetaData(this,metaData)




    validateattributes(metaData,{'char'},{'nonempty'});


    signalID=[];


    runIDs=this.getAllRunIDs;
    runCount=length(runIDs);


    for i=1:runCount
        sigIDs=this.getAllSignalIDs(runIDs(i),'leaf');
        for j=1:length(sigIDs)
            id=sigIDs(j);

            metaD=this.getMetaData(id);


            if ischar(metaD)&&strcmp(metaData,metaD)
                signalID=id;
                return;
            end
        end
    end

