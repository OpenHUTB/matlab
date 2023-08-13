classdef LayerFactory<handle

    properties(Constant,Hidden)

        RequiredFields={'HereTileId','TileCenterHere2dCoordinate',...
        'TileCenterHere3dCoordinate'}
    end

    methods(Static)

        function data=create(partitions,fields)



            layer=string(unique(partitions.Layer));


            if isempty(fields)
                read=@driving.internal.heremaps.LayerFactory.readAvailable;
            else
                read=@(x)driving.internal.heremaps.LayerFactory.readSpecified(x,fields);
            end


            for idx=1:height(partitions)
                data(idx,1)=driving.heremaps.(layer).create(...
                read(partitions(idx,:)),partitions(idx,:));
            end
        end

    end

    methods(Static,Access=private)

        function rawData=readAvailable(partition)

            rawData=drivingReadHDLMPartition(partition.Layer,...
            partition.FilePath);
        end

        function rawData=readSpecified(partition,fields)

            desiredFields=union(fields,...
            driving.internal.heremaps.LayerFactory.RequiredFields);
            rawData=drivingReadHDLMPartition(partition.Layer,...
            partition.FilePath,true,desiredFields);
        end

    end

end