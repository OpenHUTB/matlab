function info=getReducedBlocksInfo(cvd)

    info=[];
    rb=cvd.modelinfo.reducedBlocks;

    for idx=1:numel(rb)
        name=[];
        try
            crb=rb{idx};
            ssid=crb{1};
            name=getfullname(Simulink.ID.getHandle(ssid));
            cvId=SlCov.CoverageAPI.getCovId(name,[]);
            if SlCov.CoverageAPI.hasAnyCoverage(cvId,cvd)
                continue;
            end
        catch %#ok<CTCH>

        end
        if~isempty(name)
            tinfo.namedlink=sprintf('<a href="matlab: SlCov.CovStyle.selectObject(''%s'');">%s</a>',ssid,name);
            tinfo.rationale=crb{2};
            tinfo.idx='';
            if isempty(info)
                info=tinfo;
            else
                info(end+1)=tinfo;
            end

        end
    end