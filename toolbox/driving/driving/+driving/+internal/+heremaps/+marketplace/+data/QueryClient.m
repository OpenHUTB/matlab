classdef QueryClient<driving.internal.heremaps.marketplace.ResourceClient

    properties(Constant,Access=protected)

        APIName='Query'

        APIVersion='v1'
    end

    properties(SetAccess=private)

        Catalog char


        Version(1,1)double{mustBeInteger,mustBeNonnegative}
    end

    properties(Constant,Access=private)


        AdditionalFields=["checksum","dataSize","compressedDataSize"]
    end

    methods

        function this=QueryClient(catalog,version)

            this@driving.internal.heremaps.marketplace.ResourceClient(catalog);
            this.Catalog=catalog;
            this.Version=version;
        end

        function partitions=readTiledPartitions(this,layers,tileIDs)


            partitions=cell(size(layers));
            for idx=1:numel(layers)
                url=this.getURLWithPath('layers',layers{idx},'partitions');


                url=driving.internal.heremaps.utils.addQueryParameter(...
                url,struct('partition',tileIDs),'repeating');

                partitions{idx}=this.readPartitions(url);
            end
        end

        function T=readDataHandles(this,layers,tileIDs)


            response=this.readTiledPartitions(layers,tileIDs);
            numLayerPartitions=cellfun(@numel,response);
            response=response(numLayerPartitions>0);


            if isempty(response)
                error(message('driving:heremaps:EmptyPartitionsResponse'));
            end



            numPartitions=sum(numLayerPartitions);
            T=driving.internal.heremaps.PartitionTable.createTable(numPartitions);
            T.Catalog=string(repmat({this.Catalog},numPartitions,1));
            T.Version=repmat(this.Version,numPartitions,1);

            idx=1;
            for i=1:numel(response)
                for j=1:numel(response{i})
                    data=response{i}(j);
                    T.TileId(idx)=uint32(str2double(data.partition));
                    T.Layer(idx)=driving.internal.heremaps.LayerType.convert(data.layer);
                    T.DataHandle(idx)=data.dataHandle;
                    if isfield(data,'checksum')
                        T.Checksum(idx)=data.checksum;
                    end
                    idx=idx+1;
                end
            end


            T(~T.Layer.isReadable,:)=[];
            T=sortrows(T,{'Layer','TileId'});
        end

    end

    methods(Access=protected)

        function partitions=readPartitions(this,url)


            url=driving.internal.heremaps.utils.addQueryParameter(...
            url,struct(...
            'version',this.Version,...
            'additionalFields',this.AdditionalFields));

            try
                response=read(this,url);
                this.validateResponse(response,'partitions',...
                {'partition','layer','dataHandle'});
                partitions=response.partitions;
            catch
                partitions=[];
            end
        end

    end

end