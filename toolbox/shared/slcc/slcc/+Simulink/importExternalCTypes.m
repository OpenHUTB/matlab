function result=importExternalCTypes(headerFiles,varargin)
    try
        get_param(0,'version');
        result=slccprivate('importCustomCodeTypes',headerFiles,varargin{1:end});
    catch ME
        throw(ME);
    end
end
