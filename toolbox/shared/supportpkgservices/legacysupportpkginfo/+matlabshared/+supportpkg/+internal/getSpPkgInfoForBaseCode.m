function registryDataObj=getSpPkgInfoForBaseCode(varargin)

    switch nargin
    case 1
        basecode=varargin{1};
        opts=struct();
    case 2
        basecode=varargin{1};
        opts=varargin{2};
    otherwise
        error('Incorrect number of parameters provided');
    end
    validateattributes(basecode,{'char','cell'},{'nonempty'},'getSpPkgInfoForBaseCode','basecode',1);

    basecode=cellstr(basecode);
    validateattributes(opts,{'struct'},{},'getSpPkgInfoForBaseCode','opts',2);
    if~isfield(opts,'debugFlag')
        opts.debugFlag=false;
    end
    if opts.debugFlag
        opts.DebugLog=@(s)disp(s);
    else
        opts.DebugLog=@(s)[];
    end
    validateattributes(opts.debugFlag,{'logical'},{'nonempty'},'getSpPkgInfoForBaseCode','opts.debugFlag');
    registryDataObj=matlabshared.supportpkg.internal.LegacySupportPackageRegistryInfo.empty;
    try
        allPluginClasses=matlabshared.supportpkg.internal.findAllRegistryPlugins();
        currBaseCode='';
        for i=1:numel(basecode)
            currBaseCode=basecode{i};
            dataForBaseCode=getRegistryDataFromPlugin(currBaseCode,allPluginClasses);
            registryDataObj=[registryDataObj;dataForBaseCode];%#ok<AGROW>
        end
    catch ex
        baseException=MException(message('supportpkgservices:registryplugin:UnableToGetSpPkgInfo',currBaseCode));
        baseException=addCause(baseException,ex);
        throwAsCaller(baseException);
    end

end


function registryDataObj=getRegistryDataFromPlugin(basecode,pluginMetaClasses)
    foundPluginClass=matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase.findSpPkgPluginForBaseCode(basecode,pluginMetaClasses);

    if isempty(foundPluginClass)
        registryDataObj=matlabshared.supportpkg.internal.LegacySupportPackageRegistryInfo.empty;
        return
    end
    foundPluginObj=matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase.constructPluginClasses(foundPluginClass);
    registryFileDir=foundPluginObj.getRegistryFileDir();
    registryDataObj=foundPluginObj.readSpPkgRegistry(fullfile(registryFileDir,...
    matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase.XmlFileName));
    assert(strcmp(foundPluginObj.BaseCode,registryDataObj.BaseCode),sprintf('Mismatch between registry XML base code (%s) and plugin base code (%s)',registryDataObj.BaseCode,foundPluginObj.BaseCode));
end

