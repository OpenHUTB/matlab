classdef ConnectedRegion<handle














    properties


        BlockHandles(1,:)double;


        OrigSpan(1,4)double=[0,0,0,0];


        UpdatedSpan(1,4)double=[0,0,0,0];



        HierarchyIdx(1,1)Simulink.internal.variantlayout.Hierarchy=...
        Simulink.internal.variantlayout.Hierarchy.HORIZONTAL;


        HasLeft(1,1)logical=true;


        HasRight(1,1)logical=true;


        HasDown(1,1)logical=true;


        HasTop(1,1)logical=true;


        BlkPaths(1,:)cell;


        Annotations(1,:)double;


        VerticalPartitionIndex(1,1)double;


        HorizontalPartitionIndex(1,1)double;


        VerticalRank(1,1)double;


        HorizontalRank(1,1)double;
    end

    methods
        function obj=ConnectedRegion(blkHandles)
            if nargin>0
                obj.BlockHandles=blkHandles;
                obj.OrigSpan=Simulink.internal.variantlayout.ConnectedRegion.findBoundingArea(blkHandles);
                obj.UpdatedSpan=obj.OrigSpan;

                anotId=1;
                blkPathId=1;
                for blkIdx=1:numel(blkHandles)
                    if strcmp(get(blkHandles(blkIdx),'Type'),'annotation')
                        obj.Annotations(anotId)=blkHandles(blkIdx);
                        anotId=anotId+1;
                    else
                        obj.BlkPaths{blkPathId}=getfullname(blkHandles(blkIdx));
                        blkPathId=blkPathId+1;
                    end
                end
                obj.determineHierarchy;
            end
        end






        function determineHierarchy(obj)


            orientations=get_param(obj.BlkPaths,'Orientation');



            numLeft=sum(strcmp(orientations,'left'));
            numRight=sum(strcmp(orientations,'right'));

            numUp=sum(strcmp(orientations,'up'));
            numDown=sum(strcmp(orientations,'down'));


            if numLeft+numRight>=numUp+numDown
                obj.HierarchyIdx=Simulink.internal.variantlayout.Hierarchy.HORIZONTAL;
            else
                obj.HierarchyIdx=Simulink.internal.variantlayout.Hierarchy.VERTICAL;
            end


            obj.HasLeft=numLeft>0;
            obj.HasRight=numRight>0;
            obj.HasDown=numDown>0;
            obj.HasTop=numUp>0;
        end


        function setRegionPosition(obj,deltaVec)
            for blkId=1:numel(obj.BlockHandles)
                oldPos=get(obj.BlockHandles(blkId),'Position');
                newPos=oldPos+[deltaVec,deltaVec];
                try
                    set(obj.BlockHandles(blkId),'Position',newPos);
                catch
                end
            end
        end


        function updateSpan(obj)
            obj.UpdatedSpan=Simulink.internal.variantlayout.ConnectedRegion.findBoundingArea(obj.BlockHandles);
        end
    end

    methods(Static)

        function maxSpan=findBoundingArea(blkHandles)
            if isempty(blkHandles)
                maxSpan=0;
                return;
            end
            maxSpan=get(blkHandles(1),'Position');

            for blkId=2:numel(blkHandles)
                position=get(blkHandles(blkId),'Position');
                if position(1)<maxSpan(1)
                    maxSpan(1)=position(1);
                end
                if position(2)<maxSpan(2)
                    maxSpan(2)=position(2);
                end
                if position(3)>maxSpan(3)
                    maxSpan(3)=position(3);
                end
                if position(4)>maxSpan(4)
                    maxSpan(4)=position(4);
                end
            end
        end
    end
end


