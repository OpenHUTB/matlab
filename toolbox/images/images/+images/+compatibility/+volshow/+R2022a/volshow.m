
classdef(Sealed,ConstructOnLoad)volshow<handle&matlab.mixin.SetGet&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer
    properties(Dependent)




Parent






Alphamap






Colormap




Lighting






IsosurfaceColor



Isovalue


















Renderer










CameraPosition







CameraUpVector







CameraTarget







CameraViewAngle






BackgroundColor







ScaleFactors








InteractionsEnabled

    end

    properties(Transient,Hidden=true,GetAccess=public,SetAccess=protected)
        Type matlab.internal.datatype.matlab.graphics.datatype.TypeName='volshow';
    end

    properties(Access=private)

viewerView
viewerModel
viewerController

        InteractableInternal=true;

    end

    properties(Transient,Access=private)

LifeCycleListener

    end

    methods




        function self=volshow(V,varargin)


            images.internal.app.volview.checkOpenGLDrivers();


            if~images.internal.app.volview.isVolume(V)
                error(message('images:volumeViewer:requireVolumeData'));
            end

            supportedImageClasses={'int8','uint8','int16','uint16','int32','uint32','single','double','logical'};
            supportedImageAttributes={'real','nonsparse','nonempty'};
            validateattributes(V,supportedImageClasses,supportedImageAttributes,mfilename,'V');


            if islogical(V)&&~iptgetpref('VolumeViewerUseHardware')
                error(message('images:volumeViewer:hardwareRequired'));
            end


            self.viewerModel=images.internal.app.volviewToolgroup.Model();
            self.viewerModel.loadNewVolumeData(V,'volume');


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

            set(self.viewerView.VolumePanel,'Visible','on');

        end




        function setVolume(self,V)






            if~images.internal.app.volview.isVolume(V)
                error(message('images:volumeViewer:requireVolumeData'));
            end

            supportedImageClasses={'int8','uint8','int16','uint16','int32','uint32','single','double','logical'};
            supportedImageAttributes={'real','nonsparse','nonempty'};
            validateattributes(V,supportedImageClasses,supportedImageAttributes,mfilename,'V');

            self.viewerModel.loadVolumeData(V,'volume');

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


            self.viewerModel.triggerVolumeDataChange();


            self.Renderer=self.Renderer;


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
                'AutoResizeChildren','off',...
                'Visible','off',...
                'HandleVisibility','off');
            else

                hFig=figure;
                set(hFig,'AutoResizeChildren','off');
                self.viewerView.VolumePanel=uipanel('Parent',hFig,...
                'BorderType','none',...
                'Units','normalized',...
                'Position',[0,0,1,1],...
                'AutoResizeChildren','off',...
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




        function set.Renderer(self,renderStr)

            self.viewerModel.Renderer=renderStr;
        end

        function renderStr=get.Renderer(self)
            renderStr=self.viewerModel.Renderer;
        end




        function set.Isovalue(self,isoval)

            self.viewerModel.setIsovalue(isoval);
        end

        function isoval=get.Isovalue(self)
            isoval=self.viewerModel.getIsovalue;
        end




        function set.IsosurfaceColor(self,c)
            self.viewerModel.setIsosurfaceColor(convertColorSpec(images.internal.ColorSpecToRGBConverter,c));
        end

        function c=get.IsosurfaceColor(self)
            c=self.viewerModel.getIsosurfaceColor;
        end




        function set.Alphamap(self,alphaMapIn)
            validateattributes(alphaMapIn,{'numeric'},...
            {'size',[256,1],'finite','nonnegative','nonsparse','nonempty','real','<=',1},...
            mfilename,'Alphamap');
            self.viewerModel.setAlphamapVol(double(alphaMapIn'));
        end

        function alphaMapIn=get.Alphamap(self)
            alphaMapIn=self.viewerModel.getAlphamap;
            alphaMapIn=alphaMapIn';
        end




        function set.Colormap(self,colorMapIn)
            validateattributes(colorMapIn,{'numeric'},...
            {'size',[256,3],'finite','nonnegative','nonsparse','nonempty','real','<=',1},...
            mfilename,'Colormap');
            self.viewerModel.setColormapVol(double(colorMapIn));
        end

        function colorMapIn=get.Colormap(self)
            colorMapIn=self.viewerModel.getColormap;
        end




        function set.Lighting(self,lighting)
            if isnumeric(lighting)
                lighting=logical(lighting);
            end
            validateattributes(lighting,{'logical'},{'scalar','nonempty'},...
            mfilename,'Lighting');
            self.viewerModel.setLighting(lighting);
        end

        function lighting=get.Lighting(self)
            lighting=self.viewerModel.getLighting;
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
