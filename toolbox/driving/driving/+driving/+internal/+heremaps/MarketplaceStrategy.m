classdef MarketplaceStrategy<driving.internal.heremaps.DataServiceStrategy




    properties(Constant,Hidden)
        CredentialsTokens={'AccessKeyID','AccessKeySecret'}
        ValidationURL=driving.internal.heremaps.marketplace.Constants.PlatformBaseURL
        CatalogLayerMap=containers.Map('KeyType','char','ValueType','any')
    end

    properties(Access=protected)
        Token char
        TokenExpiration(1,1)double
    end

    methods(Hidden)

        function T=getPartitionMetadata(this,partitions)








            if isKey(this.CatalogLayerMap,this.Catalog)
                layers=this.CatalogLayerMap(this.Catalog);
            else

                configClient=driving.internal.heremaps.marketplace.data.ConfigClient();


                layers=configClient.readLayers(this.Catalog,'heretile');
                L=driving.internal.heremaps.LayerType.convert(layers);
                layers=layers(isReadable(L));


                localMap=this.CatalogLayerMap;
                localMap(this.Catalog)=layers;%#ok<NASGU>
            end

            T=this.MetadataService.readDataHandles(layers,partitions);
        end

        function[url,options]=attachCredentials(this,url,options,credentials)

            if isempty(this.Token)||posixtime(datetime('now'))>this.TokenExpiration
                id=credentials.AccessKeyID;
                secret=credentials.AccessKeySecret;

                auth=driving.internal.heremaps.marketplace.AuthenticationAuthorizationClient(id,secret);
                [this.Token,this.TokenExpiration]=auth.requestToken();
            end


            options.KeyName='Authorization';
            options.KeyValue=['Bearer ',this.Token];
        end

        function deleteCredentials(this)

            this.Token='';
            this.TokenExpiration=0;
        end

        function data=testReplaceUrl(~,testingAuthority,url,options)


            path='v1/catalogs/hrn:here:data::olp-here-had:here-hdlm-protobuf-';
            encodedPath=strrep(url.EncodedPath,path,'');

            if(contains(url.Host,'lookup'))
                path1='hrn:here:data::olp-here-had:here-hdlm-protobuf-';
                encodedPath=strrep(encodedPath,path1,'');
                url.EncodedPath=encodedPath;
            elseif(contains(url.Host,'metadata'))
                url.EncodedPath=encodedPath;
            elseif(contains(url.Host,'query'))
                url.EncodedPath=encodedPath+"/"+string(url.Query(1).Value)+"/";
                url.EncodedQuery="";
            elseif(contains(url.Host,'config'))
                queryStr="";
                if(numel(url.Query)>0)
                    for indx=1:numel(url.Query)
                        queryStr=queryStr+"/"+url.Query(indx).Name+...
                        "/"+url.Query(indx).Value;
                    end
                    url.EncodedPath="/config"+encodedPath+queryStr+"/";
                    url.EncodedQuery="";
                end
            end

            url.EncodedAuthority=testingAuthority;
            url.Scheme='http';
            options.ContentType='json';
            data=webread(url,options);
        end

        function catalogs=getCatalogs(this)
            if isempty(this.Catalogs)
                configClient=driving.internal.heremaps.marketplace.data.ConfigClient();
                this.Catalogs=configClient.getAvailableCatalogs;
            end
            catalogs=this.Catalogs;
        end

    end

    methods(Static)

        function service=getDataClient(cache)
            service=driving.internal.heremaps.marketplace.data.BlobClient(cache);
        end

        function client=getVersionClient(catalog)
            client=driving.internal.heremaps.marketplace.data.MetadataClient(catalog);
        end

        function client=getMetadataClient(catalog,catalogVersion)
            client=driving.internal.heremaps.marketplace.data.QueryClient(...
            catalog,catalogVersion);
        end

    end
end