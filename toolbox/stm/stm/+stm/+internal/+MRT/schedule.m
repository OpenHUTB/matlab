function[errorId,errorMsg]=schedule(imtPkg,releaseNames,releaseLocations,workspaceRoot)





    errorId='';
    errorMsg='';
    try
        if(~isempty(releaseNames)&&~isempty(releaseLocations))
            resultSetIdList=zeros(1,length(imtPkg));
            areAllDisabled=true;

            for k=1:length(imtPkg)
                resultSetIdList(k)=imtPkg.resultSetId;
                totalResults=stm.internal.getResultObjectProp(resultSetIdList(k),'TotalResults');
                disabledResults=stm.internal.getResultObjectProp(resultSetIdList(k),'NumDisabled');
                areAllDisabled=(totalResults==disabledResults);
            end


            if(areAllDisabled)
                return;
            end

            stm.internal.MRT.utility.MultiReleaseTestLauncher(imtPkg,releaseNames,...
            releaseLocations,workspaceRoot);
            stm.internal.processPCTResults(int32(resultSetIdList));
        end
    catch err
        errorId=err.identifier;
        errorMsg=err.message;
    end
end

