


classdef MultiShapeLabelers<handle

    properties(Access=private)
ImageSize
ShapeLabelers
PointCloudLimits
    end

    methods
        function this=MultiShapeLabelers()
        end


        function tf=isMultipleROIselected(this,eroi,evt)
            tf=false;
            N=0;
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    roi=thisLabeler.CurrentROIs{n};





                    if(eroi==roi)&&(evt.PreviousSelected&&evt.CurrentSelected)||...
                        (eroi~=roi)&&roi.Selected
                        N=N+1;
                        if N>1
                            tf=true;
                            return;
                        end
                    end
                end
            end
        end


        function tf=isMouseClickedOnASelectedROI(this,eroi,evt)

            tf=false;
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    roi=thisLabeler.CurrentROIs{n};




                    if(eroi==roi)&&(evt.PreviousSelected&&evt.CurrentSelected)
                        tf=true;
                        return;
                    end
                end
            end
        end


        function doLabelIsSelectedPre(this,shapeLabelers,varargin)

            this.ShapeLabelers=shapeLabelers;
            srcObj=varargin{1};
            src=varargin{2}.Data.src;
            evt=varargin{2}.Data.evt;

            if isMultipleROIselected(this,src,evt)&&...
                isMouseClickedOnASelectedROI(this,src,evt)&&...
                (strcmp(evt.SelectionType,'left')||strcmp(evt.SelectionType,'shift'))

            else
                for lIdx=1:numel(this.ShapeLabelers)
                    if isa(srcObj,class(this.ShapeLabelers(lIdx)))
                        onROISelection(this.ShapeLabelers(lIdx),src);
                    end
                end
            end
        end

        function offset=computeOffsetMovement(this,src,evt)
            pos=src.Position;

            if isRectangle(src.Type)


                pos(1)=pos(1)-0.5;
                pos(2)=pos(2)-0.5;

                pos=round(pos);

                pos(1)=pos(1)+0.5;
                pos(2)=pos(2)+0.5;

            elseif isProjectedCuboid(src.Type)

                pos(1)=pos(1)-0.5;
                pos(2)=pos(2)-0.5;
                pos(5)=pos(5)-0.5;
                pos(6)=pos(6)-0.5;

                pos=round(pos);

                pos(1)=pos(1)+0.5;
                pos(2)=pos(2)+0.5;
                pos(5)=pos(5)+0.5;
                pos(6)=pos(6)+0.5;
            end

            offsetPos=pos-evt.PreviousPosition;
            offset.x=offsetPos(1,1);
            offset.y=offsetPos(1,2);
        end


        function[minSX,minSY,maxSX,maxSY]=allowableOffsetForROI(this,type,pos)

            imSize=this.ImageSize;
            bboxPos=computeBBox(this,type,pos);
            roiW=bboxPos(3);
            roiH=bboxPos(4);
            imW=imSize(2);
            imH=imSize(1);


            minSX=-bboxPos(1)+0.5;
            minSY=-bboxPos(2)+0.5;
            maxSX=max(imW-(bboxPos(1)+roiW)+0.5,0);
            maxSY=max(imH-(bboxPos(2)+roiH)+0.5,0);
        end


        function bboxPos=computeBBox(this,type,pos)

            if isRectangle(type)
                bboxPos=pos;
            elseif(isPolyline(type)||isPolygon(type))
                bboxPos=[min(pos(:,1)),min(pos(:,2)),max(pos(:,1)),max(pos(:,2))];
                bboxPos(3)=bboxPos(3)-bboxPos(1)+0.5;
                bboxPos(4)=bboxPos(4)-bboxPos(2)+0.5;
            elseif isProjectedCuboid(type)
                bboxPos=vision.internal.labeler.tool.ProjCuboidLabeler.getBoundingBox(pos);
            else
                bboxPos=zeros(1,4);
                error('why pixel label here');
            end
        end

        function tf=isROIinsideImage(this,type,pos)

            imSize=this.ImageSize;
            bboxPos=computeBBox(this,type,pos);

            roiW=bboxPos(3);
            roiH=bboxPos(4);
            imW=imSize(2);
            imH=imSize(1);

            tf=bboxPos(1)>0&&bboxPos(2)>0&&...
            bboxPos(1)+roiW-1<=imW&&bboxPos(2)+roiH-1<=imH;
        end


        function tf=isAllowableMove(this,src,xyOffset)

            tf=true;
            if~isROIinsideImage(this,src.Type,src.Position)
                tf=false;
                return;
            end

            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    roi=thisLabeler.CurrentROIs{n};

                    if((src~=roi)&&roi.Selected)
                        pos2=addXYOffsetToPosition(this,roi.Position,roi.Type,xyOffset);
                        if~isROIinsideImage(this,roi.Type,pos2)
                            tf=false;
                            return;
                        end
                    end
                end
            end
        end


        function posOut=addXYOffsetToPosition(~,posIn,type,xyOffset)

            if isRectangle(type)
                posOut=posIn+[xyOffset.x,xyOffset.y,0,0];
            elseif(isPolyline(type)||isPolygon(type))
                posOut=[posIn(:,1)+xyOffset.x,posIn(:,2)+xyOffset.y];
            elseif isProjectedCuboid(type)
                posOut=posIn+[xyOffset.x,xyOffset.y,0,0,xyOffset.x,xyOffset.y,0,0];
            else
                posOut=[posIn(:,1)+xyOffset.x,posIn(:,2)+xyOffset.y];
                error('why pixel label here');
            end
        end


        function[minSX,minSY,maxSX,maxSY]=maxStartOffsetToSnapToBorder(this,src,evt)

            prevPos=evt.PreviousPosition;

            [minSX,minSY,maxSX,maxSY]=allowableOffsetForROI(this,src.Type,prevPos);

            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    roi=thisLabeler.CurrentROIs{n};

                    if((src~=roi)&&roi.Selected)
                        pos=roi.Position;
                        [minSX_,minSY_,maxSX_,maxSY_]=allowableOffsetForROI(this,roi.Type,pos);
                        minSX=max(minSX,minSX_);
                        minSY=max(minSY,minSY_);
                        maxSX=min(maxSX,maxSX_);
                        maxSY=min(maxSY,maxSY_);
                    end
                end
            end
        end

        function tf=roiBeingResized(this,type,evt)

            tf=false;
            if isRectangle(type)||isPolyline(type)


                prevBBox=computeBBox(this,type,evt.PreviousPosition);
                currBBox=computeBBox(this,type,evt.CurrentPosition);
                prevWH=prevBBox(3:4);
                currWH=currBBox(3:4);



                TOL=1e-5;
                if abs(prevWH(1)-currWH(1))>TOL||abs(prevWH(2)-currWH(2))>TOL
                    tf=true;
                end
            elseif isProjectedCuboid(type)



                tf=isequal(evt.PreviousPosition,evt.CurrentPosition);
            end
        end


        function tf=isTheLabelROI(this,roi,labelName)

            tf=false;




            copiedData=this.ShapeLabelers.getCopiedData(roi);
            ud=copiedData.UserData;
            if strcmp(copiedData.Tag,labelName)&&isempty(ud{2})&&isempty(ud{3})
                tf=true;
            end
        end


        function modifyLabelNameInCurrentROIs(this,shapeLabelers,oldLabelName,newLabelName)
            this.ShapeLabelers=shapeLabelers;
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    thisROI=thisLabeler.CurrentROIs{n};
                    if thisLabeler.checkROIValidity(thisROI)
                        if isTheLabelROI(this,thisROI,oldLabelName)




                            copiedData=this.ShapeLabelers.getCopiedData(thisROI);
                            if isempty(thisROI.Label)
                                copiedData.Label='';
                            else
                                copiedData.Label=newLabelName;
                            end
                            copiedData.Tag=newLabelName;
                            this.ShapeLabelers.changeROIProperty(thisROI,copiedData);

                        end
                    end
                end
            end
        end

        function doMoveMultipleROI(this,shapeLabelers,imageSize,varargin)

            this.ShapeLabelers=shapeLabelers;
            this.ImageSize=imageSize;
            src=varargin{1}{2}.Data.src;
            evt=varargin{1}{2}.Data.evt;
            xyOffset=computeOffsetMovement(this,src,evt);





            if roiBeingResized(this,src.Type,evt)
                if~isAllowableMove(this,src,xyOffset)
                    src.Position=evt.PreviousPosition;
                end
                return;
            end

            if isAllowableMove(this,src,xyOffset)
                for lIdx=1:numel(this.ShapeLabelers)
                    thisLabeler=this.ShapeLabelers(lIdx);
                    for n=1:numel(thisLabeler.CurrentROIs)
                        roi=thisLabeler.CurrentROIs{n};

                        if((src~=roi)&&roi.Selected)
                            newPosition=addXYOffsetToPosition(this,roi.Position,roi.Type,xyOffset);
                            roi.Position=newPosition;
                        end
                    end
                end
            else


                [minSX,minSY,maxSX,maxSY]=maxStartOffsetToSnapToBorder(this,src,evt);
                xyOffset_clip.x=clip(xyOffset.x,minSX,maxSX);
                xyOffset_clip.y=clip(xyOffset.y,minSY,maxSY);

                prevPos=evt.PreviousPosition;
                src.Position=addXYOffsetToPosition(this,prevPos,src.Type,xyOffset_clip);

                for lIdx=1:numel(this.ShapeLabelers)
                    thisLabeler=this.ShapeLabelers(lIdx);
                    for n=1:numel(thisLabeler.CurrentROIs)
                        roi=thisLabeler.CurrentROIs{n};

                        if((src~=roi)&&roi.Selected)
                            newPosition=addXYOffsetToPosition(this,roi.Position,roi.Type,xyOffset_clip);
                            roi.Position=newPosition;
                        end
                    end
                end
            end
        end

        function doMoveMultipleCuboidROIs(this,shapeLabelers,limits,varargin)


            this.ShapeLabelers=shapeLabelers;
            this.PointCloudLimits=limits;
            src=varargin{1}{2}.Data.src;
            evt=varargin{1}{2}.Data.evt;




            if isa(src,'vision.roi.Polyline3D')
                return;
            end



            if~isequal(evt.PreviousPosition(4:6),evt.CurrentPosition(4:6))
                return;
            end

            offset=evt.CurrentPosition(1:3)-evt.PreviousPosition(1:3);



            if offset(1)~=0
                val=1;
            elseif offset(2)~=0
                val=2;
            elseif offset(3)~=0
                val=3;
            else
                return;
            end
            [allowCuboidMove,maxOffset]=computeOffset(this,src,offset(val),val);
            offset(val)=maxOffset;

            if~allowCuboidMove
                prevPos=evt.PreviousPosition;
                prevPos(1:3)=prevPos(1:3)+offset;
                src.Position=prevPos;
            end

            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                if isa(thisLabeler,'driving.internal.groundTruthLabeler.tool.Line3DLabeler')
                    for n=1:numel(thisLabeler.CurrentROIs)
                        roi=thisLabeler.CurrentROIs{n};

                        if((src~=roi)&&roi.Selected)
                            roi.Position=roi.Position+offset;
                        end
                    end
                else
                    for n=1:numel(thisLabeler.CurrentROIs)
                        roi=thisLabeler.CurrentROIs{n};

                        if((src~=roi)&&roi.Selected)
                            roi.Position(1:3)=roi.Position(1:3)+offset;
                        end
                    end
                end
            end
        end

        function[allowCuboidMove,maxOffset]=computeOffset(this,src,offset,val)
            limits=sort(this.PointCloudLimits(val,:));
            allowCuboidMove=true;
            [isCuboidIn,offset]=isCuboidInLimits(this,src,limits,offset,val);
            if~isCuboidIn
                allowCuboidMove=false;
            end
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    roi=thisLabeler.CurrentROIs{n};
                    [isCuboidIn,offset]=isCuboidInLimits(this,roi,limits,offset,val);

                    if~isCuboidIn
                        allowCuboidMove=false;
                    end
                end
            end
            maxOffset=offset;
        end

        function[isCuboidIn,newOffset]=isCuboidInLimits(~,roi,limits,offset,val)
            point=roi.Position(val);
            pointLength=roi.Position(val+3);
            if limits(1)>offset+point
                newOffset=limits(1)-point;
                isCuboidIn=false;
            elseif limits(2)<offset+point+pointLength
                newOffset=limits(2)-point-pointLength;
                isCuboidIn=false;
            else
                newOffset=offset;
                isCuboidIn=true;
            end
        end

    end
end

function out=clip(in,minV,maxV)

    if in==0
        out=in;
    elseif in<0
        out=max(in,minV);
    else
        out=min(in,maxV);
    end
end

function tf=isProjectedCuboid(type)
    tf=strcmpi(type,'vision.roi.ProjectedCuboid');
end

function tf=isRectangle(type)
    tf=strcmp(type,'images.roi.rectangle');
end

function tf=isPolyline(type)
    tf=strcmp(type,'images.roi.polyline');
end

function tf=isPolygon(type)
    tf=strcmp(type,'images.roi.polygon');
end
