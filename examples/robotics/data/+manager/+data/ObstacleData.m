classdef ObstacleData<manager.data.ObjDataBase



    properties

TopLeftX


TopLeftY


Width


Height


    end

    methods
        function obj=ObstacleData()
            obj.TopLeftX=[];
            obj.TopLeftY=[];
            obj.Width=[];
            obj.Height=[];

        end

        function[status,message]=AddObject(obj,clickedGrid,map)



            obj.TopLeftX=[obj.TopLeftX;min(clickedGrid(:,1))];
            obj.TopLeftY=[obj.TopLeftY;max(clickedGrid(:,2))];
            obj.Width=[obj.Width;abs(clickedGrid(1,1)-clickedGrid(2,1))+1];
            obj.Height=[obj.Height;abs(clickedGrid(1,2)-clickedGrid(2,2))+1];

            status=1;
            message.Message=['Occupancy added. Top left grid: ',num2str(obj.TopLeftX(end)),', ',num2str(obj.TopLeftY(end)),...
            ' Width: ',num2str(obj.Width(end)),' Height: ',num2str(obj.Height(end))];
            message.Color='black';
        end

        function[status,removedData,message]=RemoveObject(obj,grid)

            for i=1:size(obj.TopLeftX,1)
                if grid(1,1)-obj.TopLeftX(i)<obj.Width(i)&&grid(1,1)-obj.TopLeftX(i)>0...
                    &&obj.TopLeftY(i)-grid(1,2)<obj.Height(i)&&obj.TopLeftY(i)-grid(1,2)>0
                    removedData.TopLeftX=obj.TopLeftX(i);
                    removedData.TopLeftY=obj.TopLeftY(i);
                    removedData.Width=obj.Width(i);
                    removedData.Height=obj.Height(i);


                    obj.TopLeftX(i)=[];
                    obj.TopLeftY(i)=[];
                    obj.Width(i)=[];
                    obj.Height(i)=[];


                    message.Message=['Occupancy removed. Top left grid: ',num2str(removedData.TopLeftX),', ',num2str(removedData.TopLeftY),...
                    ' Width: ',num2str(removedData.Width),' Height: ',num2str(removedData.Height)];
                    message.Color='black';
                    break;
                end
            end
            status=1;
        end

        function[status,message]=EditObject(obj,row,gridVal)

            storedVal=[obj.TopLeftX,obj.TopLeftY,obj.Width,obj.Height];


            idx=find(all(~(storedVal-gridVal),2),1);
            if isempty(idx)
                obj.TopLeftX(row)=gridVal(1);
                obj.TopLeftY(row)=gridVal(2);
                obj.Width(row)=gridVal(3);
                obj.Height(row)=gridVal(4);
                status=true;

                message.Message=['Obstacle updated to X: ',num2str(gridVal(1)),...
                ' Y: ',num2str(gridVal(2)),' Width: ',num2str(gridVal(3)),...
                ' Height: ',num2str(gridVal(4))];
                message.Color='black';
            else

                status=false;
                message.Message='Obstacle present with same properties';
                message.Color='red';
            end
        end

        function posTable=getTable(obj)

            if~isempty(obj.TopLeftX)
                posTable=table(obj.TopLeftX,obj.TopLeftY,obj.Width,obj.Height,'VariableNames',{'X','Y','Width','Height'});
            else
                posTable=table([],[],[],[],...
                'VariableNames',{'X','Y','Width','Height'});
            end
        end

        function clearData(obj)

            obj.TopLeftX=[];
            obj.TopLeftY=[];
            obj.Width=[];
            obj.Height=[];

        end

        function nObj=getNumObj(obj)

            nObj=size(obj.TopLeftX,1);
        end
    end
end

