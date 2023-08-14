function status=createLinks(srcDomainList,srcArtifactList,srcItemIDList,dstDomainList,dstArtifactList,dstItemIDList,linktype)

    if slreq.app.MainManager.exists()
        mgr=slreq.app.MainManager.getInstance;
        mgr.notify('SleepUI');
        cleanup=onCleanup(@()mgr.notify('WakeUI'));
    end
    linkExportData=cell(size(srcItemIDList));
    for index=1:length(srcItemIDList)
        srcItemID=srcItemIDList{index};
        dstItemID=dstItemIDList{index};
        linkExportData{index}=slreq.report.rtmx.utils.createLinkFromMatrix(srcDomainList{index},srcArtifactList{index},srcItemID,dstDomainList{index},dstArtifactList{index},dstItemID,linktype);
        if strcmpi(srcDomainList{index},'matlabcode')
            inputSrcLines=strsplit(srcItemIDList{index},'-');
            if length(inputSrcLines)==2
                linkExportData{index}.SrcTextLines{end+1}={str2double(inputSrcLines{1}),str2double(inputSrcLines{2})};
            end
        end

        if strcmpi(dstDomainList{index},'matlabcode')
            inputDstLines=strsplit(dstItemIDList{index},'-');
            if length(inputDstLines)==2
                linkExportData{index}.DstTextLines{end+1}={str2double(inputDstLines{1}),str2double(inputDstLines{2})};
            end

        end
    end

    status=jsonencode(linkExportData);
end
