classdef DataStoreStrategy<driving.internal.heremaps.DataServiceStrategy

    properties(Constant,Hidden)
        CredentialsTokens={'AppID','AppCode'}
        ValidationURL='https://here-hdmap-ext-weu-1.catalogs.datastore.api.here.com/v2/catalog/versions/latest?startVersion=-1'
        CatalogDataURLMap=containers.Map('KeyType','char','ValueType','any');
    end

    methods(Hidden)

        function T=getPartitionMetadata(this,partitions)









            T=this.MetadataService.readDataHandles(partitions);


            if isKey(this.CatalogDataURLMap,this.Catalog)
                dataURLs=this.CatalogDataURLMap(this.Catalog);
            else

                configClient=...
                driving.internal.heremaps.datastore.ConfigurationClient(this.Catalog);
                dataURLs=configClient.readDataURLs('heretile');


                localMap=this.CatalogDataURLMap;
                localMap(this.Catalog)=dataURLs;%#ok<NASGU>
            end


            for idx=1:height(T)
                T.DataURL(idx)=dataURLs(char(T.Layer(idx).Name));
            end
        end

        function[url,options]=attachCredentials(~,url,options,credentials)
            creds=struct(...
            'app_id',credentials.AppID,...
            'app_code',credentials.AppCode);
            url=driving.internal.heremaps.utils.addQueryParameter(...
            url,creds);
        end

        function data=testReplaceUrl(~,testingAuthority,url,options)





            isInsideLabsMockServer=contains(testingAuthority,'mockhereserver');
            if(~isInsideLabsMockServer)







                if(isempty(url.Host))
                    disp('empty data found')
                    data=[];
                end

                hostparts=url.Host.split('.');
                url.EncodedPath=hostparts(1)+url.EncodedPath;

                if(url.EncodedPath.contains("partition"))
                    queryparm=url.Query(1);
                    for indx=1:numel(queryparm.Value)
                        url.EncodedPath=url.EncodedPath+"/"+queryparm.Name+"/"+string(queryparm.Value(1))+"/test";
                        url.EncodedAuthority=testingAuthority;
                        url.Scheme='http';
                        options.ContentType='json';
                        data=webread(url,options);
                        disp("found multiple partitions");
                    end
                    return;
                end


                if(url.EncodedPath.contains("versions")&&~url.EncodedPath.contains("latest"))
                    url.EncodedPath=url.EncodedPath+"/"+url.Query(1).Name;
                end
            end
            url.EncodedAuthority=testingAuthority;
            url.Scheme='http';
            options.ContentType='json';
            data=webread(url,options);
        end

        function catalogs=getCatalogs(this)
            if isempty(this.Catalogs)
                s=settings;
                c=s.driving.heremaps.catalogs;
                cats=cellfun(@(r)c.(r).ActiveValue,properties(c),...
                'UniformOutput',false);
                cats=cellstr(cats);
                this.Catalogs=cats(cellfun(@(x)~isempty(x),cats));
            end
            catalogs=this.Catalogs;
        end

    end

    methods(Static)

        function service=getDataClient(cache)
            service=driving.internal.heremaps.datastore.DataClient(cache);
        end

        function client=getVersionClient(catalog)
            client=driving.internal.heremaps.datastore.VersionClient(catalog);
        end

        function client=getMetadataClient(catalog,catalogVersion)
            client=driving.internal.heremaps.datastore.PartitionClient(...
            catalog,catalogVersion);
        end

    end
end