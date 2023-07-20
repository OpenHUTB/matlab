function out=getReportFolder(~)
    cfg=Simulink.fileGenControl('getConfig');
    out=fullfile(cfg.CacheFolder,'slprj','sdi');
end
