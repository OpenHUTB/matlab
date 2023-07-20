function navigate(domain,artifact,artifactID)

    if strcmp(domain,'link')||strcmp(domain,'linkset')
        slreq.app.CallbackHandler.selectObjectByUuid(artifactID,'standalone');
        return;
    end

    targetInfo=slreq.report.rtmx.utils.Misc.getTargetStruct(domain,artifact,artifactID);

    if strcmp(domain,'matlabcode')

        range=sscanf(targetInfo.id,'%d-%d')';
        edit(targetInfo.artifact);
        if isempty(range)
            range=[1,1];
        end
        rmiut.RangeUtils.setSelection(targetInfo.artifact,range);

        return;
    elseif strcmp(domain,'simulink')&&contains(artifactID,'~')
        idInfo=strsplit(artifactID,'~');
        [~,artifactName]=fileparts(artifact);
        blockPath=[artifactName,idInfo{1}];
        codeID=idInfo{2};
        rmicodenavigate(blockPath,codeID);

        return

    end

    slreq.show(targetInfo);
end