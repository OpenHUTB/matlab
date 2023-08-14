classdef Launcher<handle




    properties(SetAccess=protected)
modelName
subscription
channelName
pluginChannelName
mf0Model
mf0channelName
connectorChannel
sync
url
cef

        baseURL='toolbox/ssm/ssm_app/genericUI/index.html'
        debugBaseUrl='toolbox/ssm/ssm_app/genericUI/index-debug.html'

vizDebuggerObj
    end

    methods
        function delete(obj)
            obj.cef.close();
            obj.cleanup();
            delete(obj.vizDebuggerObj);
            ssm.app.Launcher.instance(obj.modelName,'clear');
        end
    end

    methods(Access=private)
        function cleanup(obj)
            message.unsubscribe(obj.subscription);
        end

        function receiveMessage(obj,msg)
            switch msg

            case 'run'

                obj.vizDebuggerObj.preRunSetup();
                set_param(obj.modelName,'SimulationCommand','start');
            case 'pause'
                set_param(obj.modelName,'SimulationCommand','pause');
            case 'continue'
                set_param(obj.modelName,'SimulationCommand','continue');
            case 'step'
                st=Simulink.SimulationStepper(obj.modelName);
                st.forward;
            case 'stop'
                set_param(obj.modelName,'SimulationCommand','stop');

                obj.vizDebuggerObj.postRunCleanup();
            case 'sdi'
                Simulink.sdi.view


            case 'open'
                [obj.mf0Model,ret]=ssm.app.open(obj.mf0Model);
                ret.command='responseToUIInteraction';
                obj.sendMessage(ret);
                obj.cef.bringToFront;
            case 'save'
                ret=ssm.app.save(obj.mf0Model);
                ret.command='responseToUIInteraction';
                obj.sendMessage(ret);
                obj.cef.bringToFront;
            case 'generateTopLevelModelAndRun'

                obj.vizDebuggerObj.preRunSetup();

                ret=ssm.app.generateRunCallback(...
                obj.mf0Model,obj.modelName);
                ret.command='responseToUIInteraction';
                obj.sendMessage(ret);
                obj.cef.bringToFront;
            end
        end

        function onModelChangeListener(obj,added,modified,deleted)






            for i=1:length(added)

                if isa(added(i),'ssm.app.Plugin')
                    plugin=ssm.plugin.addPlugin(obj.modelName,...
                    strcmp(added(i).mode,'sync'),...
                    eval(['@',added(i).functionName]));
                    added(i).json=jsonencode(plugin);
                end


                if(isa(added(i),'ssm.app.VizDebuggerSettings'))
                    ret=obj.vizDebuggerObj.settingsChange(added(i));
                    ret.command='responseToUIInteraction';
                    obj.sendMessage(ret);
                end
            end


            for i=1:length(modified)

                if(isa(modified(i),'ssm.app.VizDebuggerSettings'))
                    ret=obj.vizDebuggerObj.settingsChange(modified(i));
                    ret.command='responseToUIInteraction';
                    obj.sendMessage(ret);
                end
            end


            for i=1:length(deleted)

                if isa(deleted(i),'ssm.app.Plugin')
                    ssm.plugin.removePlugin(jsondecode(deleted(i).json));
                end
            end
        end

        function sendMessage(obj,msg)
            message.publish(obj.pluginChannelName,msg);
        end

        function unsubscribe(obj)
            message.unsubscribe(obj.subscription);
        end

        function registerPlugin(obj)
            plugin={};
            plugin.channelName=['/SSMPluginManager/',obj.modelName,'/genericUI'];
            plugin.subscription=0;
            plugin.modelName=obj.modelName;
            plugin.synchronous=false;
            plugin.isMATLABPlugin=false;

            ssm.plugin.allPlugins('add',plugin);
            obj.pluginChannelName=plugin.channelName;
        end

        function obj=Launcher(modelName,varargin)

            if~isempty(varargin{1})&&isa(varargin{1}{1},'mf.zero.Model')
                obj.mf0Model=varargin{1}{1};
                varargin{1}(1)=[];
            else
                obj.mf0Model=mf.zero.Model;
            end
            obj.mf0Model.registerObservingListener(@obj.onModelChangeListener);

            obj.mf0channelName=['/genericUI/mf0channel/',obj.mf0Model.UUID];
            obj.connectorChannel=mf.zero.io.ConnectorChannelMS(...
            obj.mf0channelName,obj.mf0channelName);
            obj.sync=mf.zero.io.ModelSynchronizer(...
            obj.mf0Model,obj.connectorChannel);
            obj.sync.start();


            obj.modelName=modelName;
            obj.channelName=['/genericUI/',obj.modelName...
            ,obj.mf0Model.UUID,'/clientUIControl'];
            obj.registerPlugin();
            obj.subscription=message.subscribe(...
            obj.channelName,@(msg)obj.receiveMessage(msg));


            obj.vizDebuggerObj=ssm.app.VizDebugger(...
            obj.modelName,obj.mf0Model);


            obj=openUI(obj,varargin);
        end

        function obj=reLauncher(obj,varargin)
            openUI(obj,varargin);
        end

        function obj=openUI(obj,varargin)
            if isempty(varargin{1}{1})

                U=matlab.net.URI(obj.baseURL);
                U.Query(1)=matlab.net.QueryParameter('modelName',...
                obj.modelName);
                U.Query(2)=matlab.net.QueryParameter('uuid',...
                obj.mf0Model.UUID);
                obj.url=connector.getUrl(U.EncodedURI);


                obj.cef=matlab.internal.webwindow('about:blank');
                obj.cef.maximize();
                obj.cef.show();
                obj.cef.URL=obj.url;
            elseif strcmp(varargin{1}{1}{1},'debug')

                U=matlab.net.URI(obj.debugBaseUrl);
                U.Query(1)=matlab.net.QueryParameter('snc','dev');
                U.Query(2)=matlab.net.QueryParameter('modelName',...
                obj.modelName);
                U.Query(3)=matlab.net.QueryParameter('uuid',...
                obj.mf0Model.UUID);
                obj.url=connector.getUrl(U.EncodedURI);
                web(obj.url,'-browser');
            else

                U=matlab.net.URI(obj.baseURL);
                U.Query(1)=matlab.net.QueryParameter('snc','dev');
                U.Query(2)=matlab.net.QueryParameter('modelName',...
                obj.modelName);
                U.Query(3)=matlab.net.QueryParameter('uuid',...
                obj.mf0Model.UUID);
                obj.url=connector.getUrl(U.EncodedURI);
                web(obj.url,'-browser');
            end
        end
    end

    methods(Static)
        function obj=instance(modelName,varargin)
            persistent launchedUIs
            if isempty(launchedUIs)
                launchedUIs=containers.Map;
            end

            if nargin>1
                if strcmp(varargin{1},'clear')
                    launchedUIs.remove(modelName);
                    obj=[];
                    return;
                end
            end

            if launchedUIs.isKey(modelName)
                obj=launchedUIs(modelName);
                obj.reLauncher(varargin);
            else
                obj=ssm.app.Launcher(modelName,varargin);
                launchedUIs(modelName)=obj;
            end
        end
    end
end
