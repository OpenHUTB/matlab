classdef DataServiceStrategy<handle




    properties(Abstract,Constant,Hidden)
        CredentialsTokens(:,1)cell
    end

    properties(Dependent)
Catalog
CatalogVersion
    end

    properties(SetAccess=protected)
MetadataService
        Catalogs(1,:)cell
    end

    methods

        function catalog=get.Catalog(this)
            catalog=this.MetadataService.Catalog;
        end

        function catalog=get.CatalogVersion(this)
            catalog=this.MetadataService.Version;
        end

    end

    methods(Hidden,Abstract)
        T=getPartitionMetadata(this,partitions)
        [url,options]=attachCredentials(this,url,options,credentials)
        data=testReplaceUrl(this,testingAuthority,url,options)
    end

    methods(Static,Abstract)
        client=getDataClient(cache)
        client=getVersionClient(catalog)
        client=getMetadataClient(catalog,catalogVersion)
    end

    methods(Hidden)

        function setCatalog(this,catalog,catalogVersion)


            try

                versionClient=this.getVersionClient(catalog);
            catch ME


                errID='driving:heremaps:CatalogNotFound';
                ex=MException(errID,getString(message(errID,catalog)));
                ex=ex.addCause(ME);
                throw(ex);
            end

            if isempty(catalogVersion)

                catalogVersion=versionClient.LatestVersion;
            elseif~versionClient.isVersionAvailable(catalogVersion)

                error(message('driving:heremaps:CatalogVersionNotAvailable',...
                catalogVersion,catalog));
            end




            this.MetadataService=this.getMetadataClient(catalog,catalogVersion);
        end

        function deleteCredentials(~)

        end

    end

end