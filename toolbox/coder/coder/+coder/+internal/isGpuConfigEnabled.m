function enabled=isGpuConfigEnabled(cfg)







    enabled=~isempty(cfg)&&...
    isprop(cfg,'GpuConfig')&&...
    ~isempty(cfg.GpuConfig)&&...
    cfg.GpuConfig.Enabled;
end
