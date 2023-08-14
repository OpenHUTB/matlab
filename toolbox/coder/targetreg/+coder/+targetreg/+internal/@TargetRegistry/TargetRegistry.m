classdef TargetRegistry<handle




    properties(SetAccess=private,GetAccess=public)
        TargetFunctionLibraries=[];
        ConnectivityConfigs={};
        ToolchainInfos={};
        TargetInfoFcns={};
    end
    properties(Dependent=true,SetAccess=private,GetAccess=public)
        Listeners;
    end
    properties(SetAccess=public,GetAccess=public)
        ListenerType='';
    end
    properties(Access=private)
        CRLQuickMapName=containers.Map('KeyType','char','ValueType','any');
        CRLQuickMapAlias=containers.Map('KeyType','char','ValueType','any');
        CRLQuickMapReqName=containers.Map('KeyType','char','ValueType','any');
        CRLQuickMapReqAlias=containers.Map('KeyType','char','ValueType','any');

        IncludesSlCustomizerRegistrations=false;

        ConfigNeedsRefresh=true;
        HwDeviceNeedsRefresh=true;
        ToolchainNeedsRefresh=true;
        CrlNeedsRefresh=true;
    end

    methods(Static)



        function value=initializedAndCached()
            value=~isempty(coder.targetreg.internal.TargetRegistry.instance());
        end



        function value=slCustomizerRegistrationsLoaded()
            value=coder.targetreg.internal.TargetRegistry.initializedAndCached()&&coder.targetreg.internal.TargetRegistry.instance.IncludesSlCustomizerRegistrations;
        end




        function tr=getWithoutDataLoad()
            mlock;

            if~coder.targetreg.internal.TargetRegistry.initializedAndCached()
                coder.targetreg.internal.TargetRegistry.initialize();
            end

            tr=coder.targetreg.internal.TargetRegistry.instance();
        end



        function resetTargetRegistryOnly()

            if coder.targetreg.internal.TargetRegistry.initializedAndCached()

                coder.targetreg.internal.TargetRegistry.instance.postEvent('reset');


                coder.targetreg.internal.TargetRegistry.instance([]);
                coder.targetreg.internal.TargetRegistry.listeners({});
            end
        end
    end

    methods

        function setIncludesSlCustomizerRegistrations(this)
            this.IncludesSlCustomizerRegistrations=true;
        end

        function allTypesNeedRefresh(this)
            this.ConfigNeedsRefresh=true;
            this.HwDeviceNeedsRefresh=true;
            this.ToolchainNeedsRefresh=true;
            this.CrlNeedsRefresh=true;
        end

        function appendTargetFunctionLibrary(this,tfl)

            this.TargetFunctionLibraries=[this.TargetFunctionLibraries;tfl];
        end

        function removeConnectivityConfig(this,idx)
            this.ConnectivityConfigs(idx)=[];
        end

        function appendConnectivityConfig(this,info)

            this.ConnectivityConfigs=[this.ConnectivityConfigs;info];
        end

        function appendToolchainInfo(this,info)

            this.ToolchainInfos=[this.ToolchainInfos;info];
        end

        function updateToolchainInfo(this,idx,info)

            this.ToolchainInfos(idx)=info;
        end

        function refreshConfig(this)

            if~this.ConfigNeedsRefresh
                return;
            end


            refresh(this,'rtw.connectivity.ConfigRegistry')
            this.ConfigNeedsRefresh=false;

        end

        function refreshToolchain(this)

            if~this.ToolchainNeedsRefresh
                return;
            end


            refresh(this,'coder.make.ToolchainInfoRegistry');
            this.ToolchainNeedsRefresh=false;
        end

        function refreshCRL(this)

            if~this.CrlNeedsRefresh
                return;
            end


            refresh(this,'RTW.TflRegistry')
            this.CrlNeedsRefresh=false;
        end




        function value=get.Listeners(~)
            value=coder.targetreg.internal.TargetRegistry.listeners();
        end




        function set.Listeners(~,value)
            coder.targetreg.internal.TargetRegistry.listeners(value);
        end
    end

    methods(Static,Access=private)


        function value=listeners(newValue)
            persistent registryListeners;

            if nargin>0
                registryListeners=newValue;
            elseif isempty(registryListeners)
                registryListeners={};
            end

            value=registryListeners;
        end



        function value=instance(newValue)
            persistent registryInstance;

            if nargin>0
                registryInstance=newValue;
            end

            value=registryInstance;
        end




        function initialize()


            tr=coder.targetreg.internal.TargetRegistry;




            if exist('getrtwDefaultTargetInfo','file')
                tr.registerTargetInfo(@getrtwDefaultTargetInfo);
            end


            tr.registerTargetInfosOnPath();

            coder.targetreg.internal.TargetRegistry.instance(tr);
        end
    end

    methods(Access=private)



        function registerTargetInfosOnPath(this)

            customizations=which('-all','/rtwTargetInfo');

            if isempty(customizations)
                return;
            end

            for i=1:length(customizations)
                paths{i}=fileparts(customizations{i});%#ok<AGROW>
            end

            [paths,indexFromCustomizations,~]=unique(paths);
            for i=1:length(paths)
                funcs{i}=builtin('_GetFunctionHandleForFullpath',customizations{indexFromCustomizations(i)});%#ok<AGROW>
            end



            for i=1:length(funcs)
                try
                    feval(funcs{i},this);
                catch me
                    msg=message('coder_target_registry:messages:errEvalrtwTargetInfo',...
                    functions(funcs{i}).file,...
                    me.message);



                    warning('RTW:targetRegistry:errEvalrtwTargetInfo','%s',msg.string());
                end
            end
        end
    end
end

