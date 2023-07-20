function varargout=runInPlugin(hDI,functionName,varargin)





    currentPluginPackage=hDI.hToolDriver.hTool.PluginPackage;


    pluginFunctionStr=sprintf('%s.%s',currentPluginPackage,functionName);
    if nargout>=1
        [varargout{1:nargout}]=feval(pluginFunctionStr,varargin{:});
    else
        feval(pluginFunctionStr,varargin{:});
    end

end