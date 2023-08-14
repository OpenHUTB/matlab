function baseCleanup(this,varargin)


    if nargin>2




        hs.oldDriver=varargin{1};
        hs.oldMode=varargin{2};
        hs.oldAutosaveState=varargin{3};
    else
        hs=varargin{1};
    end


    hdlcurrentdriver(hs.oldDriver);
    hdlcodegenmode(hs.oldMode);


    set_param(0,'AutoSaveOptions',hs.oldAutosaveState);


    if isfield(hs,'oldModulePrefix')
        gp=pir;
        restoreParam=struct('module_prefix',hs.oldModulePrefix);
        gp.initParams(restoreParam);
    end
    if isfield(hs,'oldHDLCodingStandard')
        gp=pir;
        restoreParam=struct('hdlcodingstandard',hs.oldHDLCodingStandard);
        gp.initParams(restoreParam);
    end


    this.cleanupGenmodel;


    this.clearExistingRamMap;
end


