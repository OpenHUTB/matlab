classdef(Abstract)ObjDataBase<handle








    properties

PlotMarker


MarkerColor
    end

    properties(SetObservable)

Positions
    end

    methods

        function[status,message]=AddObject(obj,grid,map)




            idx=[];


            if getOccupancy(map,grid,'world')
                status=false;
                message.Message='Object cannot be placed on top of obstacle.';
                message.Color='red';
                return
            end

            if~isempty(obj.Positions)


                idx=find(all(~(obj.Positions-grid),2));
            end
            objectType=class(obj);
            objectName=strsplit(objectType,'.');
            if isempty(idx)
                obj.Positions=[obj.Positions;grid];
                status=true;

                message.Message=['Added ',objectName{end},' at X: ',num2str(grid(1)),' Y: ',num2str(grid(2))];
                message.Color='black';
            else
                status=false;
                message.Message=[objectName{end},' already present at X: ',num2str(grid(1)),' Y: ',num2str(grid(2))];
                message.Color='red';
            end
        end

        function status=loadObjects(obj,grids)

            obj.Positions=grids;
            status=true;
        end

        function[status,idx,message]=RemoveObject(obj,grid)

            idx=[];

            if~isempty(obj.Positions)

                idx=find(all(~(obj.Positions-grid),2));
            end

            objectType=class(obj);
            objectName=strsplit(objectType,'.');
            if~isempty(idx)
                obj.Positions(idx,:)=[];
                status=true;
                message.Message=['Removed ',objectName{end},' at X: ',num2str(grid(1)),' Y: ',num2str(grid(2))];
                message.Color='black';
            else
                status=false;
                message.Message=['No ',objectName{end},' to remove at X: ',num2str(grid(1)),' Y: ',num2str(grid(2))];
                message.Color='black';
            end
        end

        function[status,message]=EditObject(obj,row,gridVal)




            idx=find(all(~(obj.Positions-gridVal),2),1);
            objectType=class(obj);
            objectName=strsplit(objectType,'.');
            if isempty(idx)
                message.Message=[objectName{end},' updated from [',num2str(obj.Positions(row,:)),'] to [',num2str(gridVal),']'];
                message.Color='black';
                obj.Positions(row,:)=gridVal;
                status=true;
            else

                status=false;
                message.Message=[objectName{end},' already present at [',num2str(obj.Positions(row,:)),']'];
                message.Color='red';
            end
        end

        function posTable=getTable(obj)

            if~isempty(obj.Positions)
                posTable=table(obj.Positions(:,1),obj.Positions(:,2),'VariableNames',{'X','Y'});
            else
                posTable=table([],[],'VariableNames',{'X','Y'});
            end
        end

        function clearData(obj)

            obj.Positions=[];
        end

        function nObj=getNumObj(obj)

            nObj=size(obj.Positions,1);
        end

    end
end

