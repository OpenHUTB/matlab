function update(this,varargin)












    p=inputParser;
    isScalarLogical=@(x)islogical(x)&&isscalar(x);
    addParameter(p,'force',false,isScalarLogical);
    addParameter(p,'secondpartition',false,isScalarLogical);
    parse(p,varargin{:});

    info=slrealtime.Target.getSoftwareInfo();
    platform=this.detectTargetPlatform();

    if(platform=="Linux")
        this.updateLinux(p);
    else
        this.updateQNX(p,info);
    end

end
