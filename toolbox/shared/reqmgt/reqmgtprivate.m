function varargout=reqmgtprivate(function_name,varargin)








    switch function_name

    case 'actx_demo_preload'
        warn_about_deprecation(function_name,'rmicom.actx_demopreload');
        rmicom.actx_demopreload();

    case 'doors_current_obj'
        warn_about_deprecation(function_name,'rmidoors.getCurrentObj');
        [varargout{1:nargout}]=rmidoors.getCurrentObj();

    case 'doors_obj_get'
        warn_about_deprecation(function_name,'rmidoors.getObjAttribute');
        [varargout{1:nargout}]=rmidoors.getObjAttribute(varargin{:});

    case 'doors_obj_set'
        warn_about_deprecation(function_name,'rmidoors.setObjAttribute');
        rmidoors.setObjAttribute(varargin{:});

    case 'doors_module_get'
        warn_about_deprecation(function_name,'rmidoors.getModuleAttribute');
        [varargout{1:nargout}]=rmidoors.getModuleAttribute(varargin{:});

    case 'doors_module_set'
        warn_about_deprecation(function_name,'rmidoors.setModuleAttribute');
        rmidoors.setModuleAttribute(varargin{:});

    case 'model_settings'
        warn_about_deprecation(function_name,'rmisl.model_settings');
        [varargout{1:nargout}]=rmisl.model_settings(varargin{:});

    otherwise

        [varargout{1:nargout}]=feval(function_name,varargin{1:end});
    end

end


function warn_about_deprecation(old_function,new_function)
    warning(message('Slvnv:reqmgt:PrivateDeprecated',old_function,new_function));
end


