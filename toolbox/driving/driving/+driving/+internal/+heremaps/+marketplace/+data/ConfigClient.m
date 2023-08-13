classdef ConfigClient<driving.internal.heremaps.marketplace.RESTClient

    properties(Constant,Access=protected)

        APIName='Config';

        APIVersion='v1'
    end

    methods

        function this=ConfigClient()

            lookup=driving.internal.heremaps.marketplace.APILookupClient.getInstance();
            this.BaseURL=lookup.getBaseURL(this.APIName,this.APIVersion);
        end

        function hrns=getAvailableCatalogs(this)

            import driving.internal.heremaps.marketplace.Constants;


            params={...
            'verbose',true,...
            'organizationType','here',...
            'layerType','versioned'};

            baseUrl=this.getURLWithPath('catalogs');

            hrns={};


            q=Constants.CatalogSearchStr;
            for idx=1:numel(q)
                url=driving.internal.heremaps.utils.addQueryParameter(...
                baseUrl,struct(params{:},'q',q{idx}));
                resp=read(this,url);

                if isfield(resp,'results')&&isfield(resp.results,'items')
                    catalogs=resp.results.items;
                    if~iscell(catalogs)
                        catalogs=num2cell(catalogs);
                    end
                    for jdx=1:numel(catalogs)
                        hrns=[hrns,catalogs{jdx}.hrn];%#ok<AGROW>
                    end
                end
            end


            hrns=unique(hrns);
            hrns=hrns(endsWith(hrns,...
            Constants.CatalogConfigVersion));
        end

        function config=readCatalogConfiguration(this,catalog)

            url=this.getURLWithPath('catalogs',catalog);
            config=read(this,url);
            this.validateResponse(config,'layers',{'id','partitioningScheme'});
        end

        function layerIds=readLayers(this,catalog,desiredPartitioning)


            config=this.readCatalogConfiguration(catalog);
            layers=config.layers;


            if~iscell(layers)
                layers=num2cell(layers);
            end


            desired=true(size(layers));

            if nargin==3

                for idx=1:numel(layers)
                    desired(idx)=contains(layers{idx}.partitioningScheme,desiredPartitioning);
                end
            end

            if~any(desired)
                error(message('driving:heremaps:ConfigurationLayersNotFound'));
            end

            L=layers(desired);
            layerIds=cell(size(L));
            for idx=1:numel(L)
                layerIds{idx}=L{idx}.id;
            end
        end

    end

end