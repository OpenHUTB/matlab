

function out=getInstance()

    mlock;
    persistent mappingMgr;
    if isempty(mappingMgr)
        mappingMgr=slreq.app.MappingFileManager();

        mappingMgr.resetToFactoryDefaults();
    end

    out=mappingMgr;
end
