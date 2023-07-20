
classdef(Sealed,ConstructOnLoad)labelvolshow<handle&matlab.mixin.SetGet&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer
    properties(Dependent)




Parent










CameraPosition







CameraUpVector







CameraTarget







CameraViewAngle






BackgroundColor







ShowIntensityVolume






LabelColor








LabelOpacity







LabelVisibility








VolumeOpacity







VolumeThreshold







ScaleFactors








InteractionsEnabled
    end

    properties(GetAccess=public,SetAccess=private)



LabelsPresent
    end

    properties(Transient,Hidden=true,GetAccess=public,SetAccess=protected)
        Type matlab.internal.datatype.matlab.graphics.datatype.TypeName='labelvolshow';
    end

    properties(Access=private)
viewerView
viewerModel
viewerController

ShowIntensityVolumeInternal
        InteractableInternal=true;
    end

    properties(Dependent,Hidden)
NumLabels
    end

    properties(Transient,Access=private)
LifeCycleListener
    end

    methods



        function self=labelvolshow(L,varargin)

            V=[];

            images.internal.app.volview.checkOpenGLDrivers();


            validateLabeledVolume(L);


            if~isempty(varargin)&&~ischar(varargin{1})&&~isstring(varargin{1})
                if~isstruct(varargin{1})
                    V=varargin{1};
                    varargin=varargin(2:end);
                    validateVolume(V);
                    if~isequal(size(L),size(V))
                        error(message('images:volumeViewer:volumeSizesNotEqual'));
                    end
                end
            end


            self.viewerModel=images.internal.app.volviewToolgroup.Model();

            if isempty(V)
                self.ShowIntensityVolumeInternal=0;
                self.viewerModel.loadDataFromWorkspace(L,'labels');
            else
                self.ShowIntensityVolumeInternal=1;
                self.viewerModel.loadNewMixedVolumeData(V,L);
            end


            if~isempty(varargin)&&~ischar(varargin{1})&&~isstring(varargin{1})
                config=varargin{1};
                validateattributes(config,{'struct'},{'nonempty','scalar'},mfilename,'CONFIG')
                varargin=varargin(2:end);

                fields=fieldnames(config);
                for i=1:numel(fields)
                    set(self,fields{i},config.(fields{i}));
                end
            end


            parseInputs(self,varargin{:});

        end




        function setVolume(self,L,V)















            validateLabeledVolume(L);


            if nargin==3
                validateVolume(V);
                self.viewerModel.loadMixedVolumeData(V,L);
                self.ShowIntensityVolume=1;
            else
                self.viewerModel.replaceLabeledVolumeData(L);
                self.ShowIntensityVolume=self.ShowIntensityVolumeInternal;
            end
        end
    end

    methods(Access=private)

        function parseInputs(self,varargin)

            varargin=matlab.images.internal.stringToChar(varargin);


            if~isempty(varargin)


                [hInteract,varargin]=extractInputNameValue(varargin,'InteractionsEnabled');


                [hScale,varargin]=extractInputNameValue(varargin,'ScaleFactors');



                [hParent,varargin]=extractInputNameValue(varargin,'Parent');


                if~isempty(varargin)
                    set(self,varargin{:});
                end



                if isempty(hParent)
                    hFig=gcf;
                    removeToolbarFromFigure(hFig);
                    self.Parent=hFig;
                else
                    self.Parent=hParent;
                end

                if~isempty(hScale)
                    self.ScaleFactors=hScale;
                end

                if~isempty(hInteract)
                    self.InteractionsEnabled=hInteract;
                end

            else

                hFig=gcf;
                removeToolbarFromFigure(hFig);
                self.Parent=hFig;
            end

        end

        function attachVolshowToParent(self)

            if~isempty(self.Parent)

                hParent=self.Parent;


                if~isprop(hParent,'IPTVolshowManager')
                    iptVolshowManager=hParent.addprop('IPTVolshowManager');
                    iptVolshowManager.Hidden=true;
                    iptVolshowManager.Transient=true;
                end






                hParent.IPTVolshowManager=self;




                self.LifeCycleListener=addlistener(hParent,'ObjectBeingDestroyed',@(~,~)delete(self));

            end

        end

        function detachVolshowFromParent(self)

            if~isempty(self.Parent)

                hParent=self.Parent;



                if isprop(hParent,'IPTVolshowManager')
                    hParent.IPTVolshowManager=[];
                end


                delete(self.LifeCycleListener);

            end

        end

        function updateProperties(self,TF)


            self.BackgroundColor=self.BackgroundColor;


            if self.ShowIntensityVolume
                self.viewerModel.triggerMergedVolumeDataChange();
            else
                self.viewerModel.triggerLabeledVolumeDataChange();
            end


            self.viewerModel.triggerRendererChange();


            self.CameraPosition=self.CameraPosition;


            self.ScaleFactors=self.ScaleFactors;

            self.InteractionsEnabled=TF;
        end

    end


    methods




        function set.Parent(self,hPanel)

            if isempty(hPanel)||~isvalid(hPanel)
                error(message('images:volumeViewer:invalidParent'));
            end

            if~isa(hPanel,'matlab.ui.Figure')&&~isa(hPanel,'matlab.ui.container.Panel')
                error(message('images:volumeViewer:parentNotSupported'));
            end

            hFig=ancestor(hPanel,'figure');
            if strcmp(hFig.Renderer,'painters')
                error(message('images:volumeViewer:paintersRenderer'));
            end

            if isempty(self.viewerController)
                TF=true;
            else
                detachVolshowFromParent(self);
                TF=self.InteractionsEnabled;
            end

            delete(self.viewerView);
            self.viewerView=[];

            delete(self.viewerController);
            self.viewerController=[];

            self.viewerView=images.internal.volshow.View();


            if isa(hPanel,'matlab.ui.container.Panel')

                self.viewerView.VolumePanel=hPanel;
            elseif isa(hPanel,'matlab.ui.Figure')

                set(hPanel,'AutoResizeChildren','off');
                self.viewerView.VolumePanel=uipanel('Parent',hPanel,...
                'BorderType','none',...
                'Units','normalized',...
                'Position',[0,0,1,1],...
                'Visible','off',...
                'HandleVisibility','off');
            else

                hFig=figure;
                set(hFig,'AutoResizeChildren','off');
                self.viewerView.VolumePanel=uipanel('Parent',hFig,...
                'BorderType','none',...
                'Units','normalized',...
                'Position',[0,0,1,1],...
                'Visible','off',...
                'HandleVisibility','off');
            end

            self.viewerView.createView();
            self.viewerController=images.internal.volshow.Controller(self.viewerModel,self.viewerView);

            updateProperties(self,TF);

            hFig=ancestor(self.viewerView.VolumePanel,'figure');
            set(self.viewerView.VolumePanel,'Visible','on');



            set(hFig,'Renderer','opengl');

            set(hFig,'Visible','on');

            attachVolshowToParent(self);

        end

        function hPanel=get.Parent(self)
            hPanel=self.viewerView.VolumePanel;
        end




        function set.CameraPosition(self,val)
            validateattributes(val,{'numeric'},...
            {'size',[1,3],'real','finite','nonempty','nonsparse'},...
            mfilename,'CameraPosition');
            self.viewerModel.CameraPosition=val;
        end

        function val=get.CameraPosition(self)
            val=self.viewerModel.CameraPosition;
        end




        function set.CameraUpVector(self,val)
            validateattributes(val,{'numeric'},...
            {'size',[1,3],'real','finite','nonempty','nonsparse'},...
            mfilename,'CameraUpVector');
            self.viewerModel.CameraUpVector=val;
        end

        function val=get.CameraUpVector(self)
            val=self.viewerModel.CameraUpVector;
        end




        function set.CameraTarget(self,val)
            validateattributes(val,{'numeric'},...
            {'size',[1,3],'real','finite','nonempty','nonsparse'},...
            mfilename,'CameraTarget');
            self.viewerModel.CameraTarget=val;
        end

        function val=get.CameraTarget(self)
            val=self.viewerModel.CameraTarget;
        end




        function set.CameraViewAngle(self,val)
            self.viewerModel.CameraViewAngle=val;
        end

        function val=get.CameraViewAngle(self)
            val=self.viewerModel.CameraViewAngle;
        end




        function set.BackgroundColor(self,newColor)
            self.viewerModel.BackgroundColor=convertColorSpec(images.internal.ColorSpecToRGBConverter,newColor);
        end

        function color=get.BackgroundColor(self)
            color=self.viewerModel.BackgroundColor;
        end




        function set.ShowIntensityVolume(self,val)
            validateattributes(val,{'logical','numeric'},{'scalar'},mfilename,'ShowIntensityVolume');
            if isnumeric(val)
                val=logical(val);
            end

            if val&&~self.viewerModel.HasVolumeData
                error(message('images:volumeViewer:noVolumeData'));
            end
            self.ShowIntensityVolumeInternal=val;

            if val
                self.viewerModel.updateVolumeMode('mixed');
            else
                self.viewerModel.updateVolumeMode('labels');
            end
        end

        function val=get.ShowIntensityVolume(self)
            val=self.ShowIntensityVolumeInternal;
        end




        function set.LabelColor(self,val)
            validateattributes(val,{'numeric'},...
            {'size',[self.NumLabels,3],'finite','nonsparse','nonempty','real','nonnegative','<=',1},...
            mfilename,'LabelColor');

            evt.LabelIdx=1:self.NumLabels;
            evt.Value=val;
            self.viewerModel.changeLabelColor(evt);
        end

        function val=get.LabelColor(self)
            val=self.viewerModel.LabelConfig.LabelColors;
        end




        function set.LabelVisibility(self,val)
            validateattributes(val,{'logical'},...
            {'size',[self.NumLabels,1],'finite','nonsparse','nonempty','real'},...
            mfilename,'LabelVisibility');

            evt.LabelIdx=1:self.NumLabels;
            evt.Value=val;
            self.viewerModel.changeLabelVisibility(evt);
        end

        function val=get.LabelVisibility(self)
            val=self.viewerModel.LabelConfig.ShowFlags;
        end



        function set.LabelOpacity(self,val)
            validateattributes(val,{'numeric'},...
            {'size',[self.NumLabels,1],'finite','nonsparse','nonempty','real','nonnegative','<=',1},...
            mfilename,'LabelOpacity');

            evt.LabelIdx=1:self.NumLabels;
            evt.Value=val;
            self.viewerModel.changeLabelOpacity(evt,~self.ShowIntensityVolume);
        end

        function val=get.LabelOpacity(self)
            val=self.viewerModel.LabelConfig.Opacities;
        end




        function set.VolumeOpacity(self,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','nonsparse','nonempty','real','nonnegative','<=',1},...
            mfilename,'VolumeOpacity');

            self.viewerModel.setOverlayConfigVolumeOpacity(val);
        end

        function val=get.VolumeOpacity(self)
            val=self.viewerModel.OverlayConfig.OpacityValue;
        end




        function set.VolumeThreshold(self,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','nonsparse','nonempty','real','nonnegative','<=',1},...
            mfilename,'VolumeThreshold');


            threshold=floor(255*val);
            self.viewerModel.setOverlayConfigThreshold(threshold);
        end

        function val=get.VolumeThreshold(self)

            val=self.viewerModel.getOverlayConfigThreshold/255;
        end




        function set.ScaleFactors(self,scaleFactors)

            validateattributes(scaleFactors,{'numeric'},...
            {'size',[1,3],'real','finite','nonempty','nonsparse','positive'},...
            mfilename,'ScaleFactors');


            tform=self.viewerModel.Transform;


            tform(1,1)=scaleFactors(1);
            tform(2,2)=scaleFactors(2);
            tform(3,3)=scaleFactors(3);


            self.viewerModel.Transform=tform;
            self.viewerModel.CustomTransform=tform;

        end

        function scaleFactors=get.ScaleFactors(self)
            scaleFactors=[self.viewerModel.Transform(1,1),...
            self.viewerModel.Transform(2,2),...
            self.viewerModel.Transform(3,3)];
        end




        function set.InteractionsEnabled(self,TF)

            validateattributes(TF,{'logical','numeric'},...
            {'nonempty','real','scalar','nonsparse'},...
            mfilename,'InteractionsEnabled');

            self.viewerController.CameraController.Interactable=logical(TF);

        end

        function TF=get.InteractionsEnabled(self)
            TF=self.viewerController.CameraController.Interactable;
        end




        function labels=get.LabelsPresent(self)
            labels=self.viewerModel.LabelConfig.OriginalLabels;
        end




        function labels=get.NumLabels(self)
            labels=numel(self.LabelsPresent);
        end
    end
end



function removeToolbarFromFigure(hFig)


    hFig.MenuBar='none';
    hFig.ToolBar='none';

end


function[propvalue,inputs]=extractInputNameValue(inputs,propname)

    index=[];

    for p=1:2:length(inputs)


        name=inputs{p};
        TF=strncmpi(name,propname,numel(name));

        if TF
            index=p;
        end

    end

    if isempty(index)
        propvalue=[];
    else

        propvalue=inputs{index(end)+1};
        inputs([index,index+1])=[];
    end

end

function validateVolume(V)

    if~images.internal.app.volview.isVolume(V)
        error(message('images:volumeViewer:requireVolumeData'));
    end

    supportedImageClasses={'int8','uint8','int16','uint16','int32','uint32','single','double','logical'};
    supportedImageAttributes={'real','nonsparse','nonempty'};
    validateattributes(V,supportedImageClasses,supportedImageAttributes,mfilename,'V');

end

function validateLabeledVolume(L)

    if~images.internal.app.volview.isVolume(L)
        error(message('images:volumeViewer:requireVolumeData'));
    end

    if iscategorical(L)
        numLabels=numel(categories(L));
        if any(isundefined(L))
            numLabels=numLabels+1;
        end
        supportedImageAttributes={'nonsparse','real','nonempty'};
    else
        numLabels=numel(unique(L(:)));
        supportedImageAttributes={'real','nonsparse','nonempty','integer','nonnegative'};
    end
    supportedImageClasses={'int8','uint8','int16','uint16','int32','uint32','single','double','categorical'};
    validateattributes(L,supportedImageClasses,supportedImageAttributes,mfilename,'L');

    if numLabels>128
        error(message('images:volumeViewer:numLabelsExceeded'));
    end
end
