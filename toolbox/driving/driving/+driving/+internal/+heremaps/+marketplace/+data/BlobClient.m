classdef BlobClient<driving.internal.heremaps.marketplace.ResourceClient

    properties(Constant,Access=protected)

        APIName='Blob'

        APIVersion='v1'


        FileExtension=".pb";
    end

    properties(SetAccess=immutable)

        Cache driving.internal.heremaps.FileSystemCacheHandler
    end

    methods

        function this=BlobClient(cache)

            this.Cache=cache;

        end

        function filepath=saveData(this,partitions)










            filepath=this.Cache.getFilePath(this.generateFilename(partitions));
            toBeCached=~this.isCached(filepath);

            if any(toBeCached)

                partitionsToCache=partitions(toBeCached,:);
                this.prepareCache(partitionsToCache);


                catalog=unique(partitionsToCache.Catalog);
                this.setCatalogBaseURL(catalog);


                for idx=1:size(partitionsToCache,1)
                    urls(idx)=this.getURLWithPath(...
                    'layers',partitionsToCache.Layer(idx).Name,...
                    'data',partitionsToCache.DataHandle(idx));
                end



                pbFiles=filepath(toBeCached);
                gzippedFiles=strcat(pbFiles,".gz");
                this.save(gzippedFiles,urls);


                try
                    gunzip(gzippedFiles);
                catch ME
                    if strcmp(ME.identifier,'MATLAB:io:archive:gunzip:notGzipFormat')


                        for idx=1:numel(gzippedFiles)
                            [success,msg,msgid]=copyfile(gzippedFiles(idx),pbFiles(idx));
                            assert(success,msgid,msg);
                        end
                    else
                        rethrow(ME);
                    end
                end

                arrayfun(@delete,gzippedFiles);
            end

        end

        function filenames=save(this,filenames,urls)

            this.Cache.open();


            opts=weboptions(...
            'ContentType','binary',...
            'MediaType',matlab.net.http.MediaType('application/protobuf'),...
            'Timeout',driving.internal.heremaps.marketplace.Constants.WebRequestTimeout);
            m=driving.internal.heremaps.CredentialsManager.getInstance();
            [~,this.WebOptions]=m.computeRequest('',opts);

            for idx=1:numel(filenames)
                websave(filenames(idx),urls(idx),this.WebOptions);
            end
        end

        function tf=isCached(this,filename)

            tf=this.Cache.fileExists(filename);
        end

        function addCacheFolder(this,varargin)

            this.Cache.open();
            this.Cache.addFolder(varargin{:});
        end

        function filename=generateFilename(this,partitions)

            relFilename=string(partitions.Layer)+"_"+...
            partitions.TileId+this.FileExtension;
            filename=fullfile(matlab.lang.makeValidName(partitions.Catalog),...
            string(partitions.Version),relFilename);
        end

        function prepareCache(this,partitions)

            uniqueFolders=unique(partitions(:,1:3));

            for idx=1:height(uniqueFolders)
                this.addCacheFolder(matlab.lang.makeValidName(uniqueFolders.Catalog(idx)),...
                string(uniqueFolders.Version(idx)));
            end

        end

    end
end