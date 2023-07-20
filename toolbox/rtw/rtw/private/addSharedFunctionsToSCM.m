function result=addSharedFunctionsToSCM(scmFile,checksumInfo,model)






    [functionNames,clientSIDs,checksums,libBlockPath]=...
    i_processInputData(checksumInfo);


    sfInterface=SharedCodeManager.SharedFunctionInterface(scmFile);


    [existingSharedFcnIdentities,existingSharedFcnData]=i_getScmIdentities...
    (sfInterface,functionNames,clientSIDs,checksums,libBlockPath);




    scmSyncSharedFunctions(sfInterface,existingSharedFcnIdentities,...
    existingSharedFcnData,model);


    result=true;
end

function[functionNames,allClientSIDs,checksums,libBlockPaths]=i_processInputData(checksumInfo)


    numRLS=checksumInfo.NumReusableSubsystems;

    functionNames=cell(1,numRLS);
    allClientSIDs=cell(1,numRLS);
    checksums=cell(1,numRLS);
    libBlockPaths=cell(1,numRLS);

    if numRLS==0
        return
    else
        csInfo=checksumInfo.ChecksumInfo;
        if~iscell(csInfo)
            csInfo={csInfo};
        end
    end

    for i=1:numRLS

        thisCsInfo=csInfo{i};
        functionNames{i}=thisCsInfo.Name;


        clientSIDs=i_parseBlockSIDs(thisCsInfo.BlockSIDs);
        allClientSIDs{i}=clientSIDs;
        checksums{i}=thisCsInfo.Checksum;
        libBlockPaths{i}=thisCsInfo.LibraryBlockPath;

    end
end


function blockSIDs=i_parseBlockSIDs(blockSIDsCommaSeparated)

    blockSIDsCommaSeparated=...
    regexprep(blockSIDsCommaSeparated,'^,','','once');

    blockSIDs=regexp(blockSIDsCommaSeparated,',','split');
end


function[sharedFcnIdentities,sharedFcnData]=i_getScmIdentities...
    (sfInterface,functionNames,clientSIDs,checksums,libBlockPaths)

    sharedFcnIdentities=cell(size(functionNames));
    sharedFcnData=cell(size(functionNames));

    for i=1:length(functionNames)

        cs=checksums{i};
        if~isempty(cs)


            sharedIdent=SharedCodeManager.SharedFunctionIdentity(...
            uint32(cs(1)),uint32(cs(2)),uint32(cs(3)),uint32(cs(4)));




            firstIdx=1;
            sharedData=SharedCodeManager.SharedFunctionData...
            (functionNames{i},[functionNames{i},'.h'],...
            clientSIDs{i}{firstIdx},libBlockPaths{i});
        else
            sharedIdent=retrieveIdentityForName...
            (sfInterface,'SCM_SHARED_FUNCTIONS',functionNames{i});
            sharedData=retrieveDataForName...
            (sfInterface,'SCM_SHARED_FUNCTIONS',functionNames{i});
        end


        sharedData.ClientSIDs=clientSIDs{i};

        sharedFcnIdentities{i}=sharedIdent;
        sharedFcnData{i}=sharedData;

    end
end


