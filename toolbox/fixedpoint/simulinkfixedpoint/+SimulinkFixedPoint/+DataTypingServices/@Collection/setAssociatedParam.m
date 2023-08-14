function[totalRecAdded,totalNumAdded]=setAssociatedParam(this,associatedParam,runObj)





    totalNumAdded=0;
    totalRecAdded={};

    busObjectHandleMap=runObj.getMetaData.getBusObjectHandleMap();


    for kk=1:length(associatedParam)
        var=associatedParam(kk);

        curSignal=[];
        if isfield(var,'srcInfo')
            curSignal.srcInfo=var.srcInfo;
            var=rmfield(var,'srcInfo');
        end



        if isfield(var,'paramObj')
            var=rmfield(var,'paramObj');
        end


        curSignal.blkObj=var.blkObj;
        curSignal.pathItem=var.pathItem;

        [associatedRecord,recAdded,addedRecNum]=...
        this.getRecordWithBusObjectSwap(...
        curSignal,busObjectHandleMap,runObj);

        if addedRecNum>0
            totalNumAdded=totalNumAdded+addedRecNum;
            totalRecAdded(end+1:end+addedRecNum)=recAdded;
        end

        fnames=fieldnames(var);
        for jj=3:length(fnames)
            dStruct.(fnames{jj})=...
            SimulinkFixedPoint.safeConcat(...
            associatedRecord.(fnames{jj}),...
            var.(fnames{jj}));
        end


        associatedRecord.updateResultData(dStruct);
    end
end