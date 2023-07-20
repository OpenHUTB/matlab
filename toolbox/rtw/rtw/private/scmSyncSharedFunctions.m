function scmSyncSharedFunctions...
    (masterDb,thisModelSharedFcnIdentities,thisModelSharedFcnData,thisModelName)






    update=i_getUpdatedData(thisModelSharedFcnIdentities,thisModelSharedFcnData);


    previous=i_getPreviousData(masterDb,thisModelName);


    for i=1:length(previous.FunctionNames)
        lFunctionName=previous.FunctionNames{i};
        existingClientSIDs=previous.ClientSIDs{i};
        updateIdx=strcmp(update.FunctionNames,lFunctionName);
        if any(updateIdx)
            assert(sum(updateIdx)==1,'At most one function name can match')
            updateIdx=find(updateIdx,1);
            updatedClientSIDs=update.ClientSIDs{updateIdx};

            i_verifyChecksum(previous.Identities{i},previous.Data{i},...
            update.Identities{updateIdx},...
            update.Data{updateIdx});

        else
            updatedClientSIDs={};
        end


        i_updateClientSIDs(masterDb,previous.Identities{i},previous.Data{i},...
        existingClientSIDs,updatedClientSIDs);
    end


    [~,newFunctionIdx]=setdiff(update.FunctionNames,previous.FunctionNames);
    for idx=1:length(newFunctionIdx)

        i=newFunctionIdx(idx);
        masterDb.registerDataUsingCaching(update.Identities{i},update.Data{i});
    end

end

function thisModel=i_getUpdatedData(thisModelSharedFcnIdentities,thisModelSharedFcnData)
    functionNamesThisModel=cell(size(thisModelSharedFcnIdentities));
    clientSIDsThisModel=cell(size(thisModelSharedFcnIdentities));
    for i=1:length(thisModelSharedFcnIdentities)
        functionNamesThisModel{i}=thisModelSharedFcnData{i}.Name;
        clientSIDsThisModel{i}=thisModelSharedFcnData{i}.ClientSIDs;
    end

    thisModel=struct('Identities',{thisModelSharedFcnIdentities},...
    'Data',{thisModelSharedFcnData},...
    'FunctionNames',{functionNamesThisModel},...
    'ClientSIDs',{clientSIDsThisModel});
end


function previous=i_getPreviousData(masterDb,thisModelName)
    identAll=masterDb.retrieveAllIdentities('SCM_SHARED_FUNCTIONS');
    dataAll=cell(size(identAll));
    for i=1:length(dataAll)
        dataAll{i}=masterDb.retrieveData(identAll{i});
    end
    functionNames=cell(size(identAll));
    clientSIDsThisModel=cell(size(identAll));
    for i=1:length(dataAll)
        dataItem=dataAll{i};
        functionNames{i}=dataItem.FunctionName;


        thisModelClientSIDs=...
        regexp(dataItem.ClientSIDs,['^',thisModelName,':.*'],'match','once');
        emptyIdx=strcmp(thisModelClientSIDs,'');
        clientSIDsThisModel{i}=thisModelClientSIDs(~emptyIdx);
    end

    previous=struct('Identities',{identAll},...
    'Data',{dataAll},...
    'FunctionNames',{functionNames},...
    'ClientSIDs',{clientSIDsThisModel});
end


function i_updateClientSIDs(masterDb,ident,data,...
    existingClientSIDs,updatedClientSIDs)


    sidsToAdd=setdiff(updatedClientSIDs,existingClientSIDs);
    if~isempty(sidsToAdd)
        data.ClientSIDs=union(data.ClientSIDs,sidsToAdd,'stable');
        masterDb.registerDataUsingCaching(ident,data);
    end


    sidsToRemove=setdiff(existingClientSIDs,updatedClientSIDs);
    if~isempty(sidsToRemove)
        data.ClientSIDs=setdiff(data.ClientSIDs,sidsToRemove,'stable');
        masterDb.registerDataUsingCaching(ident,data);
    end
end

function i_verifyChecksum(identPrev,dataPrev,identUpdate,dataUpdate)

    gotMatch=identPrev.ChecksumElement1==identUpdate.ChecksumElement1&&...
    identPrev.ChecksumElement2==identUpdate.ChecksumElement2&&...
    identPrev.ChecksumElement3==identUpdate.ChecksumElement3&&...
    identPrev.ChecksumElement4==identUpdate.ChecksumElement4;

    if~gotMatch

        DAStudio.error('RTW:codeGen:RTWReusedFcnNameClash',...
        dataPrev.BlockSID,dataUpdate.BlockSID);
    end
end
