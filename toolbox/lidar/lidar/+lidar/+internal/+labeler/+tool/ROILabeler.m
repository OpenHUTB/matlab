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
            assert(isa(value,'lidar.internal.labeler.ROILabel')||...
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
                roiName=this.SelectedLabel.Label;
                parentName='';
            end
        end

    end

    methods(Sealed)


        function TF=checkROIValidity(~,roi)

            switch class(roi)
            case 'vision.roi.Polyline3D'
                TF=isvalid(roi)&&~isempty(roi.Position)&&size(roi.Position,1)>=roi.MinimumNumberOfPoints;
            case 'images.roi.Cuboid'
                TF=isvalid(roi)&&~isempty(roi.Position)&&all(roi.Position(4:6)>0);
            end

        end

        function copiedData=getCopiedData(~,roi)

            if isa(roi,'images.roi.Cuboid')
                copiedData.Position=[roi.CenteredPosition,roi.RotationAngle];
            else
                copiedData.Position=roi.Position;
            end



            copiedData.Label=roi.Tag;
            copiedData.Color=roi.Color;
            copiedData.UserData=roi.UserData;
            copiedData.Tag=roi.Tag;
            copiedData.Visible=roi.Visible;
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
