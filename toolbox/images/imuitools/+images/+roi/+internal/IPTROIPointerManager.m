classdef IPTROIPointerManager<handle







    properties(Transient,Hidden,Access=private)


ROI


LastKnownPointer


        WasLastObjectROI=false;


LastHitROI


MotionListener


ModeListener

    end

    properties(Dependent,Hidden)



Enabled


Pointer




ListenerEnabled

    end

    properties(Transient,Hidden)
        EnabledInternal=true;
        ListenerEnabledInternal=true;
    end

    properties(Transient,Hidden,SetAccess=private)
        IntersectionPoint=[NaN,NaN,NaN];
    end

    methods(Hidden)


        function self=IPTROIPointerManager(hFig,varargin)


            if isempty(hFig)
                hFig=figure;
            end



            if~isprop(hFig,'IPTROIPointerManager')
                iptPointerManager=hFig.addprop('IPTROIPointerManager');
                iptPointerManager.Hidden=true;
                iptPointerManager.Transient=true;
            end


            if isempty(hFig.IPTROIPointerManager)
                self.MotionListener=event.listener(hFig,'WindowMouseMotion',@(src,evt)self.motionCallback(src,evt));

                hManager=uigetmodemanager(hFig);

                self.ModeListener=event.proplistener(hManager,hManager.findprop('CurrentMode'),...
                'PostSet',@(src,evt)self.newFigureMode(src,evt));

                hFig.IPTROIPointerManager=self;
            end


            if nargin>1
                roiHandles=hFig.IPTROIPointerManager.ROI;
                hFig.IPTROIPointerManager.ROI=[roiHandles,varargin{1}];
            end

        end


        function removeROI(self,hROI)

            idx=find(self.ROI==hROI,1);

            if isempty(idx)

                return;
            end

            self.ROI(idx)=[];

        end

    end

    methods(Hidden,Access=private)


        function motionCallback(self,src,evt)































            self.IntersectionPoint=evt.IntersectionPoint;

            if~self.EnabledInternal
                return;
            end



            if~isempty(evt.HitPrimitive)
                idx=find(self.ROI==evt.HitPrimitive.Parent,1);
            else
                idx=[];
            end

            if isempty(idx)
                if self.WasLastObjectROI

                    linePointerExitFcn(self.LastHitROI);
                    self.setFigurePointer(src,self.LastKnownPointer);
                end

                self.WasLastObjectROI=false;
                return;
            end

            hROI=self.ROI(idx);

            if self.WasLastObjectROI
                if~(self.LastHitROI==hROI)

                    linePointerExitFcn(self.LastHitROI);
                end

            else

                self.LastKnownPointer=getptr(src);
                self.WasLastObjectROI=true;
            end

            self.LastHitROI=hROI;

            switch class(evt.HitPrimitive)
            case 'matlab.graphics.primitive.world.Marker'
                setPointerEnterFcn(hROI,evt.HitPrimitive);
            case 'matlab.graphics.primitive.world.LineStrip'
                setEdgeEnterFcn(hROI,evt.HitPrimitive);
            case 'matlab.graphics.primitive.world.TriangleStrip'
                setFaceEnterFcn(hROI,evt.HitPrimitive);
            case 'matlab.graphics.primitive.world.Text'
                setLabelEnterFcn(hROI,evt.HitPrimitive);
            case 'matlab.graphics.primitive.world.Quadrilateral'
                images.roi.internal.setROIPointer(src,'crosshair');
            end
        end


        function updateListenerState(self)

            if~isempty(self.MotionListener)&&isvalid(self.MotionListener)
                self.MotionListener.Enabled=self.ListenerEnabledInternal;
            end

        end

        function newFigureMode(self,~,evt)

            hManager=evt.AffectedObject;
            hMode=hManager.CurrentMode;
            if isobject(hMode)&&isvalid(hMode)&&~isempty(hMode)
                self.Enabled=false;
            else
                self.Enabled=true;
            end

        end

    end

    methods



        function set.Pointer(self,ptr)

            if isstring(ptr)||ischar(ptr)
                self.LastKnownPointer={'Pointer',char(ptr)};
            elseif iscell(ptr)
                self.LastKnownPointer=ptr;
            else
                assert(false,'Expected pointer description to be type char or cell.');
            end

        end

        function ptr=get.Pointer(self)
            ptr=self.LastKnownPointer;
        end


        function set.Enabled(self,TF)
            assert(islogical(TF)&&isscalar(TF),'Enabled must be scalar logical value.');
            self.EnabledInternal=TF;
        end

        function TF=get.Enabled(self)
            TF=self.EnabledInternal;
        end


        function set.ListenerEnabled(self,TF)
            assert(islogical(TF)&&isscalar(TF),'ListenerEnabled must be scalar logical value.');
            self.ListenerEnabledInternal=TF;
            updateListenerState(self);
        end

        function TF=get.ListenerEnabled(self)
            TF=self.ListenerEnabledInternal;
        end

    end

    methods(Static,Hidden,Access=private)


        function setFigurePointer(hFig,ptr)
            try
                if~isempty(ptr)
                    set(hFig,ptr{:});
                else

                    set(hFig,'Pointer','arrow')
                end
            catch


            end
        end

    end

end