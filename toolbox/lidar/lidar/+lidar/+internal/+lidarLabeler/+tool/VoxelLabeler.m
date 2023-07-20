
classdef VoxelLabeler<lidar.internal.labeler.tool.ROILabeler




    properties(Dependent)
LabelMatrix
Colormap
    end

    properties(Dependent)
LabelVisible
    end

    properties(Access=protected)

LabelMatrixInternal

LabelMatrixChange

ColormapInternal

PCSize
PCFilename
LabelMatrixFilename
Index
        PCChange=true
        IncludeList=1:255;
    end

    properties

        CurrentROIs={};
SelectedROIinfo
        LabelVisibleInternal='hover';
        ROIColorGroup='By Label';



        MarkersVisible='on';
    end

    properties(Access=protected)

ShapeSpec


        NumInUse=0;



ROI


        checkArray=[];

Voxel

LassoHandle

        ModeInternal='none'
    end

    properties(Access=private)
SendToBackCallbackFcn
BringToFrontCallbackFcn
    end

    properties(Access=private)
        ShowTutorial=true;

GroundRemovedPointCloud

VoxelLabelPointSize

    end

    properties(Access=protected)

PointCloud




        ROIColor=[0,1,0]




        LassoColor=[1,0,0]

        LabelVisibility(255,1)logical=true(255,1)
    end

    properties
ColorLookupTable

SelectedROI
    end

    events

DrawingStarted


DrawingFinished
    end

    methods

        function this=VoxelLabeler()


            this.ColorLookupTable=single(squeeze(lidar.internal.labeler.getColorMap('voxel')));


        end

        function finalize(this)
            commitVoxel(this);

            if~isempty(this.LabelMatrix)
                if size(this.PointCloud.Location,3)==3
                    labelData.Label=reshape(this.LabelMatrix,...
                    [size(this.PointCloud.Location,1),size(this.PointCloud.Location,2),4]);
                else
                    labelData.Label=this.LabelMatrix;
                end
                labelData.Color=[];
                labelData.Position=this.LabelMatrixFilename;
                labelData.Index=this.Index;
                labelData.Shape=lidarLabelType.Voxel;

                evtData=lidar.internal.labeler.tool.AlgorithmSetupHelperVoxelLabelEventData(labelData,false);
                notify(this,'LabelIsChanged',evtData);
            end
        end

        function info=getLabelAndColorData(this,data)

            if isempty(this.PointCloud)



                try
                    if isfield(data,'PointCloud')
                        I=data.PointCloud;
                    else
                        I=data.Image;
                    end
                catch
                    I=[];
                end
            else
                I=this.PointCloud;
            end



            info.cmap=this.getColorLookupTable();

            info.label=getVisibleLabelMatrix(this,this.LabelMatrix);
            info.I=I;
        end

        function reset(this,data)
            delete(this.Voxel);
            this.Voxel=[];

            this.PointCloud=data.Image;
            this.PCSize=size(data.Image);
            if ismatrix(data.LabelMatrix)
                this.LabelMatrix=data.LabelMatrix;
            else
                this.LabelMatrix=reshape(data.LabelMatrix,...
                size(data.LabelMatrix,1)*size(data.LabelMatrix,2),4);
            end
            this.Colormap=single(squeeze(vision.internal.labeler.getColorMap('voxel')));
            this.PCFilename=data.ImageFilename;
            this.LabelMatrixFilename=data.LabelMatrixFilename;
            this.Index=data.ImageIndex;
            this.PCChange=true;
        end

        function setLabelMatrixFilename(this,fullfilename)
            this.LabelMatrixFilename=fullfilename;
        end

        function setHandles(this,hFig,hAx,hIm)

            this.ImageHandle=hIm;
            this.AxesHandle=hAx;
            this.Figure=hFig;

        end
    end

    methods



        function commitVoxel(this)

            if this.isROIValid(this.Voxel)




            end
        end


        function deleteVoxelLabelData(this,voxelID)
            this.LabelVisibility(voxelID,1)=true;
            L=this.LabelMatrixInternal;
            L(L(:,4)==voxelID,4)=0;
            this.LabelMatrix=L;
            this.updateSemanticView();
        end










        function updateVoxelLabelerLookup(this,color,voxelID)
            this.ColorLookupTable(voxelID,:)=color;
        end


        function setGroundRemovedData(this,data)
            this.GroundRemovedPointCloud=data;
        end


        function setVoxellabelPointSize(this,val)
            this.VoxelLabelPointSize=val;
        end


        function TF=isROIValid(this,roi)




            TF=~isempty(roi);
        end


        function commitVoxelToLabelMatrix(this,selectedROI)
            L=this.LabelMatrixInternal;
            mask=this.createMask(selectedROI);
            L(mask,4)=repmat(selectedROI.UserData,size(mask));
            this.setLabelMatrixInternal(L);
        end


        function removeVoxelFromLabelMatrix(this,selectedROI)
            L=this.LabelMatrixInternal;
            mask=this.createMask(selectedROI);
            L(mask,4)=zeros(size(mask));
            this.setLabelMatrixInternal(L);
        end


        function updateSemanticView(this)
            data.PointCloud=this.PointCloud;
            data.PCFilename=this.PCFilename;
            data.Position=this.LabelMatrixFilename;
            data.Index=this.Index;
            data.ForceRedraw=true;
            data.Label=this.LabelMatrix;

            evtData=lidar.internal.labeler.tool.VoxelLabelEventData(data);

            notify(this,'LabelIsChanged',evtData);

        end
    end
    methods(Access=protected)

























    end


    methods

        function drawVoxelROI(this,lassoVertices)
            color=this.SelectedLabel.Color;

            I=this.PointCloud.Location;
            if~ismatrix(I)
                X=reshape(I(:,:,1),[],1);
                Y=reshape(I(:,:,2),[],1);
                Z=reshape(I(:,:,3),[],1);

                pointCloudData=pointCloud([X,Y,Z]);
                lassoHandle=lidar.roi.Lasso('PointCloud',pointCloudData,'Parent',this.AxesHandle);
            else
                lassoHandle=lidar.roi.Lasso('PointCloud',this.PointCloud,'Parent',this.AxesHandle);
            end

            lassoHandle.ROIColor=color;
            lassoHandle.LassoColor='y';
            lassoHandle.UserData=this.SelectedLabel.VoxelLabelID;

            cameraPosition=this.AxesHandle.CameraPosition;
            lassoHandle.select(lassoVertices,cameraPosition)

            commitVoxelToLabelMatrix(this,lassoHandle);

            this.updateSemanticView();


            lassoHandle.deleteROI;
        end


        function clearVoxelROI(this,lassoVertices)

            I=this.PointCloud.Location;
            if~ismatrix(I)
                X=reshape(I(:,:,1),[],1);
                Y=reshape(I(:,:,2),[],1);
                Z=reshape(I(:,:,3),[],1);

                pointCloudData=pointCloud([X,Y,Z]);
                lassoHandle=lidar.roi.Lasso('PointCloud',pointCloudData,'Parent',this.AxesHandle);
            else

                lassoHandle=lidar.roi.Lasso('PointCloud',this.PointCloud,'Parent',this.AxesHandle);
            end

            lassoHandle.LassoColor='w';

            cameraPosition=this.AxesHandle.CameraPosition;

            lassoHandle.clear(lassoVertices,cameraPosition);

            removeVoxelFromLabelMatrix(this,lassoHandle);

            this.updateSemanticView();


            lassoHandle.deleteROI;

        end
    end




    methods(Access=protected)

        function onButtonDown(this,varargin)

            try




                mouseClickType=get(this.Figure,'SelectionType');
                labelVal=this.SelectedLabel.VoxelLabelID;
                color=this.SelectedLabel.Color;



                switch mouseClickType
                case 'normal'

                    this.ModeInternal='draw';



                    if isempty(this.GroundRemovedPointCloud)
                        I=this.PointCloud.Location;
                        if~ismatrix(I)
                            X=reshape(I(:,:,1),[],1);
                            Y=reshape(I(:,:,2),[],1);
                            Z=reshape(I(:,:,3),[],1);

                            pointCloudData=pointCloud([X,Y,Z]);
                            lassoHandle=lidar.roi.Lasso('PointCloud',pointCloudData,'Parent',this.AxesHandle);
                        else
                            lassoHandle=lidar.roi.Lasso('PointCloud',this.PointCloud,'Parent',this.AxesHandle);
                        end
                    else
                        I=this.GroundRemovedPointCloud.Location;
                        if~ismatrix(I)
                            X=reshape(I(:,:,1),[],1);
                            Y=reshape(I(:,:,2),[],1);
                            Z=reshape(I(:,:,3),[],1);

                            this.GroundRemovedPointCloud=pointCloud([X,Y,Z]);
                        end
                        lassoHandle=lidar.roi.Lasso('PointCloud',this.GroundRemovedPointCloud,'Parent',this.AxesHandle);
                    end




                    lassoHandle.ROIColor=color;
                    lassoHandle.LassoColor='y';
                    lassoHandle.PointSize=this.VoxelLabelPointSize;
                    lassoHandle.UserData=labelVal;

                    beginSelection(lassoHandle);

                    commitVoxelToLabelMatrix(this,lassoHandle);

                    this.updateSemanticView();


                    lassoHandle.deleteROI;

                    this.ModeInternal='none';

                case 'alt'

                    this.ModeInternal='erase';

                    if isempty(this.GroundRemovedPointCloud)
                        I=this.PointCloud.Location;
                        if~ismatrix(I)
                            X=reshape(I(:,:,1),[],1);
                            Y=reshape(I(:,:,2),[],1);
                            Z=reshape(I(:,:,3),[],1);

                            pointCloudData=pointCloud([X,Y,Z]);
                            lassoHandle=lidar.roi.Lasso('PointCloud',pointCloudData,'Parent',this.AxesHandle);
                        else
                            lassoHandle=lidar.roi.Lasso('PointCloud',this.PointCloud,'Parent',this.AxesHandle);
                        end
                    else
                        I=this.GroundRemovedPointCloud.Location;
                        if~ismatrix(I)
                            X=reshape(I(:,:,1),[],1);
                            Y=reshape(I(:,:,2),[],1);
                            Z=reshape(I(:,:,3),[],1);

                            this.GroundRemovedPointCloud=pointCloud([X,Y,Z]);
                        end
                        lassoHandle=lidar.roi.Lasso('PointCloud',this.GroundRemovedPointCloud,'Parent',this.AxesHandle);
                    end

                    lassoHandle.LassoColor='w';

                    beginClearing(lassoHandle);

                    removeVoxelFromLabelMatrix(this,lassoHandle);

                    this.updateSemanticView();


                    lassoHandle.deleteROI;

                    this.ModeInternal='none';



























                end
            catch

            end
        end
    end

    methods


        function setPointer(this)
            switch this.ModeInternal
            case 'draw'

                myPointer=this.pencilPointer;
                set(this.Figure,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[16,1]);
            case 'erase'

                myPointer=transpose(this.pencilPointer);
                set(this.Figure,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[16,1]);
            otherwise
                set(this.Figure,'Pointer','arrow');
            end
        end
    end

    methods(Access=protected)

        function evtData=makeROIEventData(this,data,varargin)
            rois=this.reformatCurrentROIs(data);
            evtData=vision.internal.labeler.tool.ROILabelEventData(rois,varargin{:});
        end


        function rois=reformatCurrentROIs(this,data)
            rois=repmat(struct('ID','','ParentName','','ParentUID','','Label',[],'Position',[],'Color',[],'Shape',labelType.empty,'ROIVisibility',''),...
            numel(this.CurrentROIs),1);
            idx=1;
            for n=1:numel(data)
                data_n=data{n};
                copiedData=this.getCopiedDataVoxel(data_n);
                ud=data_n.UserData;
                rois(idx).ParentName=ud{2};
                rois(idx).ParentUID=ud{3};
                rois(idx).ID=ud{4};
                rois(idx).Label=copiedData.Tag;
                rois(idx).ROIColor=copiedData.ROIColor;
                rois(idx).Shape=this.ShapeSpec;
                rois(idx).ROIVisibility=copiedData.Visible;
                idx=idx+1;
            end
        end

    end










    methods(Access=protected)


        function L=createLabelMatrix(this)

            L=this.LabelMatrixInternal;

            if this.isROIValid(this.Voxel)&&strcmp(this.Voxel.Visible,'on')
                mask=this.createMask(this.Voxel);
                L(mask,4)=repmat(this.Voxel.UserData,size(mask));
            end
        end

    end
    methods



        function set.LabelMatrix(this,L)

            this.LabelMatrixChange=[];
            this.setLabelMatrixInternal(L);
        end


        function L=get.LabelMatrix(this)
            L=createLabelMatrix(this);
        end



        function set.Colormap(this,cmap)
            assert(size(cmap,2)==3,'Invalid Colormap');
            this.ColormapInternal=cmap;
        end

        function cmap=get.Colormap(this)
            cmap=this.ColormapInternal;
        end


        function retVar=getColorLookupTable(this)
            retVar=this.ColorLookupTable;
        end


        function setColorLookupTable(this,updatedLookupTable)


            this.ColorLookupTable=updatedLookupTable;
        end


        function setLabelVisibility(this,voxelLabelVisibility)


            this.LabelVisibility=voxelLabelVisibility;
        end



        function setLabelMatrixInternal(this,L)


            if isempty(this.LabelMatrixChange)
                this.LabelMatrixChange=L;
            else
                this.LabelMatrixChange=...
                L-this.LabelMatrixInternal;
            end
            this.LabelMatrixInternal=L;
        end


        function fileName=getImageFilename(this)

            fileName=this.ImageFilename;
        end


        function labelMatrix=getVisibleLabelMatrix(this,labelMatrix)



            if size(labelMatrix,2)<4
                return;
            end

            if~any(labelMatrix(:,4))
                return;
            end

            I=labelMatrix;
            if~ismatrix(I)
                labelMatrix=reshape(I,size(I,1)*size(I,2),4);
            end

            for i=1:size(labelMatrix,1)
                if labelMatrix(i,4)>0&&~this.LabelVisibility(labelMatrix(i,4))
                    labelMatrix(i,4)=0;
                end
            end
        end

        function mask=createMask(this,selectedROI)
            I=this.PointCloud.Location;
            if~ismatrix(I)
                pointCloudData=reshape(this.PointCloud.Location,...
                [size(this.PointCloud.Location,1)*size(this.PointCloud.Location,2),3]);
            else
                pointCloudData=this.PointCloud.Location;
            end

            [~,mask]=intersect(pointCloudData,selectedROI.LastSelection.Location,'rows');
        end


        function updateVoxelVisibility(this,selectedLabelData)

            this.LabelVisibility(selectedLabelData.VoxelLabelID,1)=...
            ~this.LabelVisibility(selectedLabelData.VoxelLabelID,1);

            this.updateSemanticView();
        end
    end

    methods(Static,Access=private)

        function myPointer=pencilPointer
            myPointer=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,2,1,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,1,2,2,1,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,1,2,1,2,1,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,2,2,1,2,1,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,1,1,2,2,2,2,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,1,2,1,2,2,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,1,2,2,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,1,2,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            1,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN];
        end

    end

end
