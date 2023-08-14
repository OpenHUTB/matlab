function out=isReady(h)




    out=~isempty(h.BuildDir)&&~isempty(h.BuildDirRoot)&&...
    exist(fullfile(h.BuildDirRoot,h.getTraceInfoFileName),'file');
