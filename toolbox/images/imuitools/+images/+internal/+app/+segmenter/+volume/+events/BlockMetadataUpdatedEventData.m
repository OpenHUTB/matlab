classdef(ConstructOnLoad)BlockMetadataUpdatedEventData<event.EventData





    properties

BlockSize
Size
SizeInBlocks
Adapter
DataSource
ClassUnderlying

    end

    methods

        function data=BlockMetadataUpdatedEventData(blockSize,sz,sizeInBlocks,adapter,src,classUnderlying)

            data.BlockSize=blockSize;
            data.Size=sz;
            data.SizeInBlocks=sizeInBlocks;
            data.Adapter=adapter;
            data.DataSource=src;
            data.ClassUnderlying=classUnderlying;

        end

    end

end