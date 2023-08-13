classdef DataServiceManager<handle

    properties(Hidden,SetAccess=private)
        DataServiceName(1,1)string
DataService
RootSettings
ServiceSettings
    end

    methods(Access=private)

        function this=DataServiceManager()
            s=settings;
            this.RootSettings=s.driving.heremaps;
            this.applyStrategy(this.RootSettings.DataService.ActiveValue);
        end

        function applyStrategy(this,strategy)
            switch strategy
            case 'DataStore'
                this.DataService=driving.internal.heremaps.DataStoreStrategy;
                this.ServiceSettings=this.RootSettings;
            case 'Marketplace'
                this.DataService=driving.internal.heremaps.MarketplaceStrategy;
                this.ServiceSettings=this.RootSettings.marketplace;
            end
            this.DataServiceName=strategy;
        end

    end

    methods(Hidden)

        function catalogs=getCatalogs(this)
            catalogs=this.ServiceSettings.catalogs;
        end

        function service=getPartitionClient(this,catalog,catalogVersion)
            service=this.DataService;
            service.setCatalog(catalog,catalogVersion);
        end

        function service=getDataClient(this,cache)
            service=this.DataService.getDataClient(cache);
        end

        function setStrategy(this,strategy)
            if~strcmp(this.RootSettings.DataService.ActiveValue,strategy)
                this.RootSettings.DataService.PersonalValue=strategy;
                this.applyStrategy(strategy);
            end
        end

    end

    methods(Static,Hidden)

        function mgr=getInstance()
            persistent manager
            if isempty(manager)
                manager=driving.internal.heremaps.DataServiceManager();
            end
            mgr=manager;
        end

    end

end