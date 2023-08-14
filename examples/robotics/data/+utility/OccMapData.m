classdef OccMapData<handle



    methods(Static)
        function UpdateOccMap(obstacle,mapDataMngr,data)





            mapRes=mapDataMngr.OccMap.Resolution;


            mapSize=mapDataMngr.OccMap.GridSize;
            nRows=mapSize(2);
            nCols=mapSize(1);

            if~isempty(obstacle.Width)
                if isa(data,'double')

                    width=obstacle.Width(data)*mapRes;
                    height=obstacle.Height(data)*mapRes;


                    topLeft=[nRows-obstacle.TopLeftY(data)*mapRes+1,obstacle.TopLeftX(data)*mapRes];

                    occValue=ones(height,width);
                elseif isa(data,'struct')
                    width=data.Width*mapRes;
                    height=data.Height*mapRes;


                    topLeft=[nRows-data.TopLeftY*mapRes+1,data.TopLeftX*mapRes];

                    occValue=zeros(height,width);
                end
            else
                topLeft=[0,0];
                occValue=zeros(nRows,nCols);
            end
            mapDataMngr.OccMap.setOccupancy(topLeft,occValue,'grid');
        end

        function EditOccMap(mapDataMngr,oldData,newData)
            mapRes=mapDataMngr.OccMap.Resolution;


            mapSize=mapDataMngr.OccMap.GridSize;
            nRows=mapSize(2);
            nCols=mapSize(1);


            oldWidth=oldData(3)*mapRes;
            oldHeight=oldData(4)*mapRes;


            oldTopLeft=[nRows-oldData(2)*mapRes+1,oldData(1)*mapRes];

            oldOccValue=zeros(oldHeight,oldWidth);

            newWidth=newData(3)*mapRes;
            newHeight=newData(4)*mapRes;


            newTopLeft=[nRows-newData(2)*mapRes+1,newData(1)*mapRes];

            newOccValue=ones(newHeight,newWidth);


            mapDataMngr.OccMap.setOccupancy(oldTopLeft,oldOccValue,'grid');


            mapDataMngr.OccMap.setOccupancy(newTopLeft,newOccValue,'grid');
        end
    end
end

