




classdef BaseItem<handle
    properties(SetAccess=private,SetObservable)
        isActive=true;
    end

    properties(SetAccess=private)
        modelName='';
        domain=[];
    end

    methods(Abstract)
        path=getPath(obj);
    end

    methods(Abstract,Access=protected)
        setupListenerForOwningObjectDeletion(obj,varargin);
    end

    methods(Abstract)
        loadedSuccessfully=reload(obj);
    end

    methods
        function obj=BaseItem(modelName,domain)
            obj.modelName=modelName;
            if~isa(domain,'Simulink.Debug.BaseItemDomainEnum')
                error('Simulink:DebuggerItem:InvalidDomainSpecified','Input domain must be of type Simulink.Debug.BaseItemDomainEnum');
            end
            obj.domain=domain;
        end

        function delObj=getDeleter(obj)
            delObj=Simulink.Debug.BaseItemDeleter(obj);
        end

        function activate(obj)
            obj.isActive=true;
        end

        function deactivate(obj)
            obj.isActive=false;
        end

        function result=belongsToModel(obj,modelName)
            result=strcmp(obj.modelName,modelName);
        end

        function prepareForDeletion(~)

        end
    end
end