classdef Partition<handle






    properties

        ConnectedRegions(1,:)Simulink.internal.variantlayout.ConnectedRegion;
        Bounds(1,4)double;
    end

    methods



        function obj=Partition(connRegion)
            if nargin>0
                obj.ConnectedRegions=connRegion;
                obj.Bounds=connRegion.UpdatedSpan;
            end
        end



        function appendRegion(obj,connRegion)
            obj.ConnectedRegions(end+1)=connRegion;
            if connRegion.UpdatedSpan(1)<obj.Bounds(1)
                obj.Bounds(1)=connRegion.UpdatedSpan(1);
            end
            if connRegion.UpdatedSpan(2)<obj.Bounds(2)
                obj.Bounds(2)=connRegion.UpdatedSpan(2);
            end
            if connRegion.UpdatedSpan(3)>obj.Bounds(3)
                obj.Bounds(3)=connRegion.UpdatedSpan(3);
            end
            if connRegion.UpdatedSpan(4)>obj.Bounds(4)
                obj.Bounds(4)=connRegion.UpdatedSpan(4);
            end
        end


        function sortRegions(obj,direction)
            posXStart=zeros(numel(obj.ConnectedRegions),1);
            posYStart=zeros(numel(obj.ConnectedRegions),1);
            posXEnd=zeros(numel(obj.ConnectedRegions),1);
            posYEnd=zeros(numel(obj.ConnectedRegions),1);


            for regionId=1:numel(obj.ConnectedRegions)




                pos=obj.ConnectedRegions(regionId).UpdatedSpan;
                posXStart(regionId)=pos(1);
                posYStart(regionId)=pos(2);
                posXEnd(regionId)=pos(3);
                posYEnd(regionId)=pos(4);
            end

            if direction==Simulink.internal.variantlayout.Hierarchy.HORIZONTAL



                [~,xSorted]=sortrows([posXStart,posXEnd]);
                tmp=obj.ConnectedRegions;
                obj.ConnectedRegions=tmp(xSorted);
                for regionIdx=1:numel(obj.ConnectedRegions)
                    obj.ConnectedRegions(regionIdx).HorizontalRank=regionIdx;
                end
            else
                [~,ySorted]=sortrows([posYStart,posYEnd]);
                tmp=obj.ConnectedRegions;
                obj.ConnectedRegions=tmp(ySorted);
                for regionIdy=1:numel(obj.ConnectedRegions)
                    obj.ConnectedRegions(regionIdy).VerticalRank=regionIdy;
                end
            end
        end


        function updateBounds(obj)
            obj.Bounds=obj.ConnectedRegions(1).UpdatedSpan;
            for connRegionId=2:numel(obj.ConnectedRegions)
                if obj.ConnectedRegions(connRegionId).UpdatedSpan(1)<obj.Bounds(1)
                    obj.Bounds(1)=obj.ConnectedRegions(connRegionId).UpdatedSpan(1);
                elseif obj.ConnectedRegions(connRegionId).UpdatedSpan(2)<obj.Bounds(2)
                    obj.Bounds(2)=obj.ConnectedRegions(connRegionId).UpdatedSpan(2);
                elseif obj.ConnectedRegions(connRegionId).UpdatedSpan(3)>obj.Bounds(3)
                    obj.Bounds(3)=obj.ConnectedRegions(connRegionId).UpdatedSpan(3);
                elseif obj.ConnectedRegions(connRegionId).UpdatedSpan(4)>obj.Bounds(4)
                    obj.Bounds(4)=obj.ConnectedRegions(connRegionId).UpdatedSpan(4);
                end
            end
        end
    end
end


