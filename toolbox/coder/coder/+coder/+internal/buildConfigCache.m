function cfg=buildConfigCache(cfgOrCmd)




    persistent buildConfigs;
    narginchk(0,1);
    if isempty(buildConfigs)&&isa(buildConfigs,'double')
        buildConfigs=coder.BuildConfig.empty(0,0);
    end
    if nargin>0
        if ischar(cfgOrCmd)||isstring(cfgOrCmd)
            coder.internal.assert(cfgOrCmd=="reset",'Coder:builtins:Explicit',...
            'Command must be "reset"');
            if~isempty(buildConfigs)
                buildConfigs(end)=[];
            end
        else
            coder.internal.assert(isa(cfgOrCmd,'coder.BuildConfig'),'Coder:builtins:Explicit',...
            'Input must be a coder.BuildCOnfig');
            if isempty(buildConfigs)
                buildConfigs=cfgOrCmd;
            else
                coder.internal.assert(isequal(cfgOrCmd,buildConfigs(end)),...
                'Coder:toolbox:BuildConfigCacheInconsitentConfig');
                buildConfigs(end+1)=cfgOrCmd;
            end
        end
    end
    if nargout>0
        coder.internal.assert(~isempty(buildConfigs),'Coder:toolbox:BuildConfigCacheNoConfig');
        cfg=buildConfigs(end);
    end
