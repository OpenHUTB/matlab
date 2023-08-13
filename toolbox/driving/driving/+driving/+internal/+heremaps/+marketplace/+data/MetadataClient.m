classdef MetadataClient<driving.internal.heremaps.marketplace.ResourceClient

    properties(Constant,Access=protected)

        APIName='Metadata'

        APIVersion='v1'
    end

    properties(SetAccess=protected)

        Catalog char


        LatestVersion double=-1
    end

    methods

        function this=MetadataClient(catalog,readLatest)

            this@driving.internal.heremaps.marketplace.ResourceClient(catalog);
            this.Catalog=catalog;
            if nargin==1||readLatest
                this.readLatestVersion();
            end
        end

        function readLatestVersion(this)


            url=this.getURLWithPath('versions','latest');




            url=driving.internal.heremaps.utils.addQueryParameter(...
            url,struct('startVersion',this.LatestVersion));


            data=read(this,url);
            this.validateResponse(data,'version');


            this.LatestVersion=data.version;
        end

        function tf=isVersionAvailable(this,version)

            validateattributes(version,{'numeric'},{'integer','scalar'});

            tf=version>0&&version<=this.LatestVersion;

            if tf
                url=this.getURLWithPath('versions','minimum');
                data=read(this,url);
                this.validateResponse(data,'version');

                tf=version>=data.version;
            end
        end

    end

end