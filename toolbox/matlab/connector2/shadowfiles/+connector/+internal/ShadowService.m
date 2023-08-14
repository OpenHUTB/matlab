classdef(Hidden)ShadowService<connector.internal.microservices.ModuleActivator


    properties
Context
Address
    end

    methods
        function obj=ShadowService(connector,address,filePath,shadowRootPath)
            obj.Context=connector.newContext;
            obj.Address=address;
            obj.loadClientTypeFile(filePath,shadowRootPath);
        end

        function loadClientTypeFile(obj,filePath,shadowRootPath)
            message=struct('type','connector/v1/LoadClientTypeFile',...
            'filePath',filePath,'shadowRootPath',shadowRootPath);

            future=obj.Context.handle(message,obj.Address);
            try
                if~future.get().success
                    warning('Unable to load client type file');
                end
            catch e
                warning('Error while loading client type. Unable to load client type file');
            end
        end
    end
end
