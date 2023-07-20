classdef VirtualAssembly<matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties

        Solution=''

        SCflag=false


        ProjPath=''
    end

    properties(SetAccess=private)

        Name='PassengerCar'

        Catalog=''

        ConfigUI=''

        Config=''
    end

    properties(Access=private)


        ProductCatalogFile=''
    end

    methods
        function obj=VirtualAssembly(varargin)
            if~isempty(varargin)
                if ischar(varargin{1})

                    varargin=[{'Name'},varargin];
                end
                set(obj,varargin{:});
            end

            obj.ProductCatalogFile=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            [obj.Name,'.xlsx']);


            if obj.SCflag
                obj.Catalog=VirtualAssembly.ProductCatalog(obj.Name,...
                'SolnModel',obj.Solution);
            end

        end

    end

    methods

        function startUI(obj)




            if obj.SCflag
                obj.ConfigUI=VirtualAssembly.VirtualView(...
                'ProductCatalog',obj.Catalog,...
                'ProductCatalogFile',obj.ProductCatalogFile);
            else

                obj.ConfigUI=VirtualAssembly.VirtualView(...
                'ProductCatalog','',...
                'ProductCatalogFile',obj.ProductCatalogFile);
            end

            obj.ConfigUI.openApp();
        end


        function features=getFeatures(obj)
            if obj.SCflag
                features=obj.Catalog.getSubFeature(obj.Name);
            else
                data=obj.ConfigUI.getProductCatalogData();
                features=data.getFeatures();
            end
        end

        function variants=getFeatureVariants(obj,feature)
            if obj.SCflag
                variants=obj.Catalog.getSubFeature(feature);
            else
                data=obj.ConfigUI.getProductCatalogData();
                variants=data.getFeatureVariants(feature);
            end
        end

        function startConfig(obj,type)
            obj.Config=VirtualAssembly.VirtualVehicleConfig(obj.Name,...
            'ProductCatalog','',...
            'ProductCatalogFile',obj.ProductCatalogFile,...
            'ProjPath',obj.ProjPath);

            switch(lower(type))
            case 'hevp0'
                obj.Config.selectFeatureVariant({'Powertrain Layout','Hybrid Electric Vehicle P0'});
                obj.Config.setConfigModelName('HEVP0');
            case 'hevp1'
                obj.Config.selectFeatureVariant({'Powertrain Layout','Hybrid Electric Vehicle P0'});
                obj.Config.setConfigModelName('HEVP1');

            otherwise
                obj.Config.selectFeatureVariant({'Powertrain Layout','Hybrid Electric Vehicle P0'});
                obj.Config.setConfigModelName('HEVP0');
            end

            obj.Config.generateVirtualVehicleModel();

        end

    end

    methods(Access=private)

    end
end
