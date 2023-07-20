function savePlot(hFig,sourceID,indx,ResultID,cnt)





    if isa(hFig.UserData,'matlabshared.scopes.UnifiedScope')
        return;
    end

    name=hFig.Name;

    if(isempty(name)&&~isempty(hFig.Children))
        try
            titleName=hFig.CurrentAxes.Title.String;
            if~isempty(titleName)
                name=titleName;
            end
        catch

        end
    end

    isPCT=ischar(ResultID);
    if isPCT
        stm.internal.saveArtifactPCT(ResultID,sourceID,indx,name,cnt,hFig);
    else
        artiID=stm.internal.saveArtifact(ResultID,sourceID,indx,name,hFig);

        md=stm.internal.artifacts.getMode(hFig);
        if(strcmp(md,'add'))
            stm.internal.updateArtifactsTempMeta(hFig.double,artiID);
        end
    end
end
