function loadReqsAndLinksFromProject(projectfiles)





    if isempty(projectfiles)
        return;
    end
    [SLMXfiles,SLREQXfiles]=filterFilesToLoad(projectfiles);

    reqData=slreq.data.ReqData.getInstance();

    for i=1:length(SLREQXfiles)
        reqData.loadReqSet(SLREQXfiles{i});
    end

    for i=1:length(SLMXfiles)





        slmxShortName=slreq.uri.getShortNameExt(SLMXfiles{i});
        reqData.loadLinkSet(slmxShortName,SLMXfiles{i});
    end




    linkSets=reqData.getLoadedLinkSets;
    for i=1:length(linkSets)
        linkSets(i).updateAllLinkDestinations();
    end
end

function[SLMXfiles,SLREQXfiles]=filterFilesToLoad(files)
    SLMXfiles={};
    SLREQXfiles={};

    for i=1:length(files)
        [~,~,ext]=fileparts(files{i});
        switch ext
        case '.slmx'
            SLMXfiles{end+1}=files{i};%#ok<AGROW>
        case '.slreqx'
            SLREQXfiles{end+1}=files{i};%#ok<AGROW>
        end
    end
end