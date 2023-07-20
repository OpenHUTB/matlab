classdef ROILabeler<handle&matlab.mixin.Heterogeneous




    properties(SetAccess=protected,GetAccess=public)



        UserIsDrawing=false;
    end

    properties


SelectedLabel


CopyCallbackFcn


CutCallbackFcn


DeleteCallbackFcn
    end

    properties(Access=private)
ButtonDownWrapperListener
    end

    properties(Access=protected)


ImageHandle



AxesHandle



Figure




        ShowLabelName=true



        AxesToolbarSelected=false
    end

    events


LabelIsChanged


ImageIsChanged



LabelIsSelectedPre



LabelIsSelected



LabelIsDeleted
    end

    methods

        function set.SelectedLabel(this,value)
            assert(isa(value,'vision.internal.labeler.ROILabel')||...
            isa(value,'vision.internal.labeler.ROISublabel'))
            this.SelectedLabel=value;
        end


        function drawLabels(~,varargin)

        end


        function data=preprocessImageData(~,data)

        end





        function finalize(~,varargin)


        end


        function pasteSelectedROIs(~,~)



        end


        function selectAll(~)



        end


        function attachToImage(this,fig,ax,imageHandle)

            this.ImageHandle=imageHandle;
            this.AxesHandle=ax;
            this.Figure=fig;
        end

        function[roiName,parentName]=getSelectedItemName(this)
            if isempty(this.SelectedLabel)
                [roiName,parentName]=deal('','');
            else

...
...
...
...
...
...
...
...
...
...
                if isprop(this.SelectedLabel,'LabelName')
                    roiName=this.SelectedLabel.Sublabel;
                    parentName=this.SelectedLabel.LabelName;
                else
                    roiName=this.SelectedLabel.Label;
                    parentName='';
                end
            end
        end

    end

    methods(Sealed)


        function TF=checkROIValidity(~,roi)

            switch class(roi)

            case 'images.roi.Rectangle'
                TF=isvalid(roi)&&~isempty(roi.Position)&&roi.Position(3)>0&&roi.Position(4)>0;
            case{'images.roi.Polygon','images.roi.Polyline','vision.roi.Polyline3D'}
                TF=isvalid(roi)&&~isempty(roi.Position)&&size(roi.Position,1)>=roi.MinimumNumberOfPoints;
            case 'vision.roi.ProjectedCuboid'
                TF=isvalid(roi)&&~isempty(roi.Position)&&roi.Position(3)>0&&roi.Position(4)>0;



            case 'images.roi.AssistedFreehand'
                TF=isvalid(roi)&&~isempty(roi.Position)&&size(roi.Position,1)>=3;
            case 'images.roi.Cuboid'
                TF=isvalid(roi)&&~isempty(roi.Position)&&all(roi.Position(4:6)>0);
            end

        end

        function copiedData=getCopiedData(~,roi)

            if isa(roi,'images.roi.Rectangle')


                pos=roi.Position;

                if(pos(1)+pos(3))<(roi.DrawingArea(1)+roi.DrawingArea(3))
                    pos(1)=pos(1)+0.5;
                end

                if(pos(2)+pos(4))<(roi.DrawingArea(2)+roi.DrawingArea(4))
                    pos(2)=pos(2)+0.5;
                end

                copiedData.Position=pos;
            elseif isa(roi,'vision.roi.ProjectedCuboid')


                pos=roi.Position;
                pos(1)=pos(1)+0.5;
                pos(2)=pos(2)+0.5;
                pos(5)=pos(5)+0.5;
                pos(6)=pos(6)+0.5;
                copiedData.Position=pos;
            elseif isa(roi,'images.roi.Cuboid')
                copiedData.Position=[roi.CenteredPosition,roi.RotationAngle];
            else
                copiedData.Position=roi.Position;
            end



            copiedData.Label=roi.Tag;
            copiedData.Color=roi.Color;
            copiedData.UserData=roi.UserData;
            copiedData.Tag=roi.Tag;
            copiedData.Visible=roi.Visible;

            if isa(roi,'images.roi.AssistedFreehand')
                copiedData.Waypoints=roi.Waypoints;
            end

        end

        function changeROIProperty(~,roi,copiedData)





            roi.Label=copiedData.Label;
            roi.Tag=copiedData.Tag;

            if isprop(roi,'UserData')&&numel(roi.UserData)>=2
                roi.UserData{2}=copiedData.UserData{2};
            end
            if~isequal(copiedData.Color,roi.Color)
                roi.Color=copiedData.Color;
            end
        end

        function label=getLabelName(this,roiName)

            if this.ShowLabelName

                label=roiName;
            else

                label='';
            end

        end

    end

    methods(Access=protected)





        function updateLabel(this,roiLabelData)

            assert(isa(roiLabelData,'vision.internal.labeler.ROILabel')||...
            isa(roiLabelData,'vision.internal.labeler.ROISublabel'))

            this.SelectedLabel=roiLabelData;

        end


        function showLabelNames(thisArray)
            for i=1:numel(thisArray)
                thisArray(i).ShowLabelName=true;
            end
        end
    end

    methods(Abstract,Access=protected)



        onButtonDown(this)
    end

    methods


        function activate(this,fig,ax,imageHandle)

            this.attachToImage(fig,ax,imageHandle);

            if isButtonDownListenerInValid(this)
                this.ButtonDownWrapperListener=addlistener(this.Figure,'WindowMousePress',...
                @(varargin)this.protectOnDelete(@this.onButtonDownWrapper,varargin{:}));
            end
        end


        function deactivate(this)


            if~isButtonDownListenerInValid(this)
                delete(this.ButtonDownWrapperListener);
            end
        end


        function toggleAxesToolbarSelected(this,flag)
            this.AxesToolbarSelected=flag;
        end
    end


    methods(Access=protected)
        function onButtonDownWrapper(this,varargin)

            if~isButtonDownOnImageValid(this,varargin{:})

                return;
            end





            if this.UserIsDrawing
                return;
            end
            this.UserIsDrawing=true;

            this.onButtonDown(varargin{:});

            this.UserIsDrawing=false;
        end


        function tf=isAxesToolbarSelected(this)
            tf=this.AxesToolbarSelected;
        end

        function tf=isButtonDownOnImageValid(this,varargin)
            tf=false;
            if numel(varargin)>=2
                eventData=varargin{2};

                if isprop(eventData,'HitObject')
                    tf=isa(eventData.HitObject,'matlab.graphics.primitive.Image')||...
                    isa(eventData.HitObject,'matlab.graphics.axis.Axes')||...
                    isa(eventData.HitObject,'matlab.graphics.chart.primitive.Scatter');
                end
            end

            tf=tf&&~isAxesToolbarSelected(this);
        end

        function imageSize=getImageSize(this)
            if isa(this.ImageHandle,'bigimageshow')
                imageSize=this.ImageHandle.CData.Size(1,:);
            else
                imageSize=size(this.ImageHandle.CData);
            end
        end

    end

    methods(Access=protected)

        function tf=isButtonDownListenerInValid(this)
            tf=isempty(this.ButtonDownWrapperListener)||~isvalid(this.ButtonDownWrapperListener);
        end

        function varargout=protectOnDelete(~,fHandle,varargin)








            try
                [varargout{1:nargout}]=fHandle(varargin{:});
            catch ME
                if strcmp(ME.identifier,'MATLAB:class:InvalidHandle')


                    return
                end
                rethrow(ME);
            end
        end

    end
end
