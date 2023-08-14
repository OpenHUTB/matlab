















classdef MapTileReaderManager<handle

    properties(Constant,Access=private)












        InitialNumMapTileReaders=18
    end

    properties(Access=private)





        MapTileReader=matlab.graphics.chart.internal.maps.MapTileAsyncReader.empty;
    end


    methods
        function manager=MapTileReaderManager






            for k=1:manager.InitialNumMapTileReaders
                manager.MapTileReader(k)=matlab.graphics.chart.internal.maps.MapTileAsyncReader;
            end
        end


        function mapTileReader=getNextAvailableReader(manager)






            activeReadersIndex=isActive(manager.MapTileReader);
            availableReader=manager.MapTileReader(~activeReadersIndex);

            if isempty(availableReader)

                mapTileReader=matlab.graphics.chart.internal.maps.MapTileAsyncReader;
                manager.MapTileReader(end+1)=mapTileReader;
            else


                index=find(~activeReadersIndex,1);
                mapTileReader=manager.MapTileReader(index);
            end
        end

        function delete(manager)





            delete(manager.MapTileReader)
        end
    end
end
