classdef(Abstract)SliceViewer<handle&matlab.mixin.SetGet

    properties(Dependent)

Parent


Colormap


DisplayRange


ScaleFactors


DisplayRangeInteraction

    end

    properties(Hidden)

        LabelColor=single([0,0,0;lines(255)]);


        LabelOpacity=single([0,ones(1,255)]);
    end


    properties(Hidden,Access=protected,Transient=true)
InternalColormap
InternalDisplayRange
InternalDisplayRangeInteraction

ImageHandles
AxesHandles

ImgStack
Labels

ImgSizeScaled

Transform
SliceManager
SliceManagerLabels

OriginalCLim


hFig
hPanel
isUIFigure
PanelSize
    end


    properties(Hidden,Access=protected,Transient=true)
MousePressEvtListener
SizeChangedListener
LifeCycleListener
ImageDestroyListener
    end

    methods(Abstract,Hidden,Access=protected)
        createViewComponents(self)
        layoutViewComponents(self)
        setupView(self)
        resetView(self)
        [widthRequired,heightRequired]=computeRequiredUISize(self,includeBordersFlag)
    end

    methods
        function self=SliceViewer()
            self.Transform=eye(4);
            self.isUIFigure=false;
            self.InternalColormap=gray(256);
            self.InternalDisplayRange=[];
        end

        function delete(self)
            delete(self.MousePressEvtListener)
            delete(self.SizeChangedListener)
            delete(self.Parent);
        end

    end

    methods(Hidden)

        function setData(self,vol,varargin)
            labels=[];
            self.Labels=[];
            if~isempty(varargin)&&isnumeric(varargin{1})
                labels=varargin{1};
            end

            self.loadData(vol,labels);

            self.setupSliceManager();

            isVolumeLogicalOrRGB=ndims(self.ImgStack)~=3||islogical(self.ImgStack);
            hasLabels=~isempty(self.Labels);
            if isVolumeLogicalOrRGB||hasLabels
                self.DisplayRangeInteraction='off';
                set(self.ImageHandles,'CDataMapping','direct');
            else
                set(self.ImageHandles,'CDataMapping','scaled');
            end

            self.resetView();

        end

        function[volume,labels]=getData(self)
            volume=self.ImgStack;
            labels=self.Labels;
        end

    end

    methods(Hidden,Access=protected)

        function setupSliceManager(self)
            self.SliceManager=images.stacks.browser.internal.SliceManager(self.ImgStack,self.Transform);

            if~isempty(self.Labels)
                self.SliceManagerLabels=images.stacks.browser.internal.SliceManager(self.Labels,self.Transform);
            end
        end

        function setDefaultDisplayRangeInteraction(self)

            isVolumeLogicalOrRGB=ndims(self.ImgStack)~=3||islogical(self.ImgStack);
            hasLabels=~isempty(self.Labels);

            if isVolumeLogicalOrRGB||hasLabels
                self.DisplayRangeInteraction='off';
            else
                self.DisplayRangeInteraction='on';
            end

        end

        function loadData(self,vol,labels)

            self.validateVolume(vol);
            self.ImgStack=vol;
            self.ImgSizeScaled=size(vol);

            if~isempty(labels)
                self.validateLabels(labels);

                if islogical(labels)
                    labels=double(labels);
                end

                self.Labels=labels;
            end

            self.OriginalCLim=double([min(self.ImgStack(:)),max(self.ImgStack(:))]);
            if~diff(self.OriginalCLim)
                self.OriginalCLim=getrangefromclass(vol);
            end

            self.DisplayRange=self.OriginalCLim;

        end

        function managePanelResize(~)


        end

        function reactToScaleFactorsChange(~)








        end

        function data=packageDataForReparenting(self)
            data.Colormap=self.Colormap;
            data.DisplayRange=self.DisplayRange;
            data.DisplayRangeInteraction=self.DisplayRangeInteraction;
        end
    end


    methods(Hidden,Access=protected)
        function setupListeners(self,src,evt)

            click=images.roi.internal.getClickType(src);
            if~strcmp(click,'left')
                return
            end



            if~isequal(class(evt.HitObject),'matlab.graphics.primitive.Image')||isModeManagerActive(self)
                return
            end
            images.internal.windowlevel(self.ImageHandles(1),self.hFig);
        end
    end


    methods

        function set.Parent(self,hParent)

            oldParent=[];
            if~isempty(self.Parent)

                oldParent=self.Parent;
                self.detachSliceViewerFromParent();
            end

            if~isa(hParent,'matlab.ui.Figure')&&~isa(hParent,'matlab.ui.container.Panel')
                error(message('images:sliceViewer:parentNotSupported'));
            end

            if~isvalid(hParent)
                error(message('images:sliceViewer:invalidParent'));
            end

            if isa(hParent,'matlab.ui.Figure')
                self.hFig=hParent;
                self.setInitialFigSize();



                pos=[0,0,self.hFig.Position(3:4)];
                self.hPanel=uipanel('Parent',hParent,'BorderType','line',...
                'Visible','on',...
                'HandleVisibility','off');






                panelUnits=self.hPanel.Units;
                self.hPanel.Units='pixels';
                self.hPanel.Position=pos;
                self.PanelSize=self.hPanel.Position(3:4);

                self.hPanel.Units=panelUnits;

            elseif isa(hParent,'matlab.ui.container.Panel')
                self.hFig=ancestor(hParent,'figure');
                self.hPanel=hParent;

                panelUnits=self.hPanel.Units;
                self.hPanel.Units='pixels';
                self.PanelSize=self.hPanel.Position(3:4);
                self.hPanel.Units=panelUnits;
            end

            self.createViewComponents();
            self.layoutViewComponents();
            self.setupView();



            self.ImageDestroyListener=addlistener(self.ImageHandles,'ObjectBeingDestroyed',@(~,~)delete(self));

            self.attachSliceViewerToParent();

            if~isempty(oldParent)
                delete(oldParent);
            end
        end

        function hParent=get.Parent(self)
            hParent=self.hPanel;
        end


        function set.Colormap(self,colormapIn)
            validateattributes(colormapIn,{'numeric'},...
            {'ncols',3,'real','finite','nonnegative','nonsparse','nonempty','<=',1},...
            mfilename,'Colormap');

            colormapIn=double(colormapIn);
            if~isempty(self.Parent)
                set(self.AxesHandles,'Colormap',colormapIn);
            end
            self.InternalColormap=colormapIn;
        end

        function colormapOut=get.Colormap(self)
            colormapOut=self.InternalColormap;
        end


        function set.ScaleFactors(self,scaleFactors)
            validateattributes(scaleFactors,{'numeric'},...
            {'size',[1,3],'real','finite','nonempty','nonsparse','positive'},...
            mfilename,'ScaleFactors');

            tform=eye(4);

            tform(1,1)=scaleFactors(1);
            tform(2,2)=scaleFactors(2);
            tform(3,3)=scaleFactors(3);


            self.Transform=tform;

            self.SliceManager=images.stacks.browser.internal.SliceManager(self.ImgStack,self.Transform);
            if~isempty(self.Labels)
                self.SliceManagerLabels=images.stacks.browser.internal.SliceManager(self.Labels,self.Transform);
            end

            oldSize=self.ImgSizeScaled;
            self.ImgSizeScaled=self.SliceManager.OutputImageSize;

            self.reactToScaleFactorsChange(oldSize);
        end

        function scaleFactors=get.ScaleFactors(self)
            scaleFactors=[self.Transform(1,1),...
            self.Transform(2,2),...
            self.Transform(3,3)];
        end


        function set.DisplayRange(self,displayRangeIn)
            if isempty(displayRangeIn)
                displayRangeIn=self.OriginalCLim;
            end

            displayRangeIn=images.internal.checkDisplayRange(displayRangeIn,mfilename);
            if~isempty(self.Parent)
                set(self.AxesHandles,'CLim',displayRangeIn)
            end
            self.InternalDisplayRange=displayRangeIn;
        end

        function displayRange=get.DisplayRange(self)
            displayRange=self.AxesHandles(1).CLim;
        end


        function set.DisplayRangeInteraction(self,val)
            validateattributes(val,{'char','string'},{'scalartext'},...
            mfilename,'DisplayRangeInteraction');

            validStr=validatestring(val,{'on','off'},mfilename,...
            'DisplayRangeInteraction');

            isVolumeLogicalOrRGB=ndims(self.ImgStack)~=3||islogical(self.ImgStack);
            hasLabels=~isempty(self.Labels);

            if isequal(validStr,'on')&&(isVolumeLogicalOrRGB||hasLabels)
                error(message('images:sliceViewer:displayRangeInteractionNotSupported'));
            end

            if~isempty(self.Parent)
                switch validStr
                case 'on'
                    self.MousePressEvtListener=event.listener(self.hFig,...
                    'WindowMousePress',@(src,evt)setupListeners(self,src,evt));
                case 'off'
                    delete(self.MousePressEvtListener);
                otherwise
                    assert(false,'Should not reach here');
                end
            end
            self.InternalDisplayRangeInteraction=validStr;
        end

        function val=get.DisplayRangeInteraction(self)
            val=self.InternalDisplayRangeInteraction;
        end


        function set.LabelColor(self,labelColor)
            validateattributes(labelColor,{'numeric'},...
            {'size',[256,3],'finite','nonsparse','nonempty','real','nonnegative','<=',1},...
            mfilename,'LabelColor');

            self.LabelColor=single(labelColor);
        end

        function labelColor=get.LabelColor(self)
            labelColor=self.LabelColor;
        end


        function set.LabelOpacity(self,labelOpacity)
            validateattributes(labelOpacity,{'numeric'},...
            {'vector','numel',256,'finite','nonsparse','nonempty','real','nonnegative','<=',1},...
            mfilename,'LabelOpacity');

            if iscolumn(labelOpacity)
                labelOpacity=labelOpacity';
            end
            self.LabelOpacity=single(labelOpacity);
        end

        function labelOpacity=get.LabelOpacity(self)
            labelOpacity=self.LabelOpacity;
        end

    end


    methods(Access=private)

        function validateVolume(~,vol)
            sizeV=size(vol);
            TF=(ndims(vol)==3||ndims(vol)==4)&&all(sizeV>1);
            if~TF
                error(message('images:sliceViewer:requireVolumeData'));
            end


            if ndims(vol)==4&&sizeV(4)~=3
                error(message('images:sliceViewer:requireVolumeData'));
            end

            if ndims(vol)==3

                supportedImageClasses={'int8','uint8','int16','uint16','int32','uint32','single','double','logical'};
            else

                supportedImageClasses={'uint8','uint16','single','double'};
            end
            supportedImageAttributes={'real','nonsparse','nonempty','finite'};
            validateattributes(vol,supportedImageClasses,supportedImageAttributes,mfilename,'S');
        end

        function validateLabels(self,labels)

            sizeV=size(labels);
            TF=ndims(labels)==3&&all(sizeV>1);
            if~TF
                error(message('images:sliceViewer:requireVolumeData'));
            end

            if self.ImgSizeScaled(1:3)~=size(labels)
                error(message('images:sliceViewer:volumeAndLabelsDifferentSize'));
            end

            supportedImageClasses={'int8','uint8','int16','uint16','int32','uint32','single','double','logical'};
            supportedImageAttributes={'real','nonsparse','nonempty','finite'};
            validateattributes(labels,supportedImageClasses,supportedImageAttributes,mfilename,'Labels');

        end

    end


    methods(Hidden,Access=protected)

        function setInitialFigSize(self)

            if isequal(get(self.hFig,'WindowStyle'),'docked')
                return
            end



            includeBordersFlag=true;
            [widthRequired,heightRequired]=self.computeRequiredUISize(includeBordersFlag);


            self.hFig.Units='pixels';



            wa=images.internal.getWorkArea;
            screenWidth=wa.width;
            screenHeight=wa.height;


            p=images.internal.figparams;

            figPos=self.hFig.Position;
            origFigWidth=figPos(3);
            origFigHeight=figPos(4);

            k=1;
            if widthRequired>screenWidth||heightRequired>screenHeight
                kWidth=screenWidth/widthRequired;
                kHeight=screenHeight/heightRequired;
                k=min(kWidth,kHeight);
            end

            newFigWidth=k*widthRequired;
            newFigHeight=k*heightRequired;


            minFigWidth=128;
            minFigHeight=128;
            newFigWidth=max(newFigWidth,minFigWidth);
            newFigHeight=max(newFigHeight,minFigHeight);


            wontFit=newFigWidth>origFigWidth||newFigHeight>origFigHeight;


            if wontFit

                figPos(1)=max(1,figPos(1)-floor((newFigWidth-origFigWidth)/2));
                figPos(2)=max(1,figPos(2)-floor((newFigHeight-origFigHeight)/2));
            end
            figPos(3)=newFigWidth;
            figPos(4)=newFigHeight;


            if wontFit



                dx=(screenWidth-p.RightDecoration)-(figPos(1)+figPos(3));
                if(dx<0)
                    figPos(1)=figPos(1)+dx;
                end
                dy=(screenHeight-p.TopDecoration)-(figPos(2)+figPos(4));
                if(dy<0)
                    figPos(2)=figPos(2)+dy;
                end
            end

            self.hFig.Position=figPos;
        end

        function TF=isModeManagerActive(self)
            hManager=uigetmodemanager(self.hFig);
            hMode=hManager.CurrentMode;
            TF=isobject(hMode)&&~isempty(hMode);
        end

        function attachSliceViewerToParent(self)

            if~isempty(self.Parent)

                hParent=self.Parent;


                if~isprop(hParent,'IPTSliceViewerManager')
                    iptSliceViewerManager=hParent.addprop('IPTSliceViewerManager');
                    iptSliceViewerManager.Hidden=true;
                    iptSliceViewerManager.Transient=true;
                end






                hParent.IPTSliceViewerManager=self;




                self.LifeCycleListener=addlistener(hParent,'ObjectBeingDestroyed',@(~,~)delete(self));
            end
        end

        function detachSliceViewerFromParent(self)

            if~isempty(self.Parent)
                hParent=self.Parent;



                if isprop(hParent,'IPTSliceViewerManager')
                    hParent.IPTSliceViewerManager=[];
                end


                delete(self.LifeCycleListener);


                delete(self.ImageDestroyListener);
            end
        end
    end

    methods(Hidden,Static)

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
    end
end