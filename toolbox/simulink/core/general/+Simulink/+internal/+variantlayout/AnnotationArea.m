classdef AnnotationArea<handle













    properties
        Margins(1,4)double=[0,0,0,0];

        Position(1,2)double;

        Size(1,2)double;

        BlockHandles(1,:)double;
        Handle(1,1)double;
    end

    methods
        function obj=AnnotationArea(annotationObject,blkPaths)
            position=annotationObject.Position;
            obj.Position=position(1:2);
            obj.Size=...
            position(3:4)-position(1:2);
            handleId=1;
            for blkId=1:numel(blkPaths)
                blkPosition=get_param(blkPaths{blkId},'Position');
                isContained=(position(1)<=blkPosition(1))&&(position(2)<=blkPosition(2))...
                &&(position(3)>=blkPosition(3))&&(position(4)>=blkPosition(4));
                if isContained
                    obj.BlockHandles(handleId)=get_param(blkPaths{blkId},'Handle');
                    handleId=handleId+1;
                end
            end
            obj.Handle=annotationObject.Handle;
            obj.findMargin;
        end


        function findMargin(obj)



            obj.Margins=get(obj.Handle,'Position')-...
            Simulink.internal.variantlayout.ConnectedRegion.findBoundingArea(obj.BlockHandles);
        end


        function setAreaPosition(obj,margin)







            if nargin==1
                margin=obj.Margins;
            end

            expectedPosition=...
            Simulink.internal.variantlayout.ConnectedRegion.findBoundingArea(obj.BlockHandles)+margin;

            set(obj.Handle,'Position',expectedPosition);
        end
    end
end


