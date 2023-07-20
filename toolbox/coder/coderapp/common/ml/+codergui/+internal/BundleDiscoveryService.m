classdef(Sealed)BundleDiscoveryService<codergui.internal.WebService




    properties(Constant,Access=private)
        SUBCHANNEL="bundleInjector/"
    end

    properties(Access=private)
Client
Subscription
    end

    methods
        function start(this,client)
            this.Client=client;
            this.Subscription=client.subscribe(this.SUBCHANNEL+"request",...
            @(~)this.sendModuleDefs());
        end

        function shutdown(this)
            this.Client.unsubscribe(this.Subscription);
        end
    end

    methods(Access=private)
        function sendModuleDefs(this)
            modDefs=this.Client.ExternalModules;
            if isstruct(modDefs)
                payload=cell(1,numel(modDefs));
                for i=1:numel(modDefs)
                    payload{i}.definition=modDefs(i);
                    payload{i}.dependencyMapJson=discoverDebugDependencies(modDefs(i));
                end
            elseif~isempty(modDefs)
                modDefs=cellstr(modDefs);
                payload=cell(1,numel(modDefs));
                for i=1:numel(modDefs)
                    file=modDefs{i};
                    if~codergui.internal.util.isAbsolute(file)
                        file=fullfile(matlabroot,file);
                    end
                    payload{i}.definition=fileread(file);
                    payload{i}.dependencyMapJson=discoverDebugDependencies(jsondecode(payload{i}.definition));
                end
            else
                payload={};
            end
            this.Client.publish(this.SUBCHANNEL+"receive",payload,true);
        end
    end
end


function depsText=discoverDebugDependencies(parsed)
    if~isfield(parsed,'bundle')||~isfield(parsed.bundle,'location')
        depsText='';
        return
    end
    jsDepsFile=fullfile(matlabroot(),fileparts(fileparts(parsed.bundle.location)),'/js_dependencies.json');
    if isfile(jsDepsFile)
        depsText=fileread(jsDepsFile);
    else
        depsText='';
    end
end