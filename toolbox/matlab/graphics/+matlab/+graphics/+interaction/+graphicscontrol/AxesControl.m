classdef AxesControl<matlab.graphics.interaction.graphicscontrol.layoutable.GridLayoutableControl




    properties
Axes
    end

    properties(Hidden,SetAccess=private)
        LockedDataSpace;
        ObjectDirtyForRecapture;
        YAxisLocationChangeListener;
    end

    methods
        function this=AxesControl(axes)
            import matlab.graphics.interaction.*
            this=this@matlab.graphics.interaction.graphicscontrol.layoutable.GridLayoutableControl(axes);
            this.Axes=axes;
            this.Type='axes';
            this.LockedDataSpace=this.Axes.ActiveDataSpace;
            this.ObjectDirtyForRecapture=true;
            this.Layoutable=true;



            this.YAxisLocationChangeListener=event.proplistener(axes,...
            findprop(axes,'YAxisLocation'),...
            'PostSet',@(~,~)this.activeDataSpaceChanged());
        end

        function response=process(this,message)
            response=struct;
            if isfield(message,'name')&&ischar(message.name)
                switch message.name
                case 'setlimits'
                    matlab.graphics.interaction.internal.initializeView(this.Obj);
                    this.setLimitsFromClient(message.limits);
                case 'getlimits'
                    recaptureIfNeeded(this);
                    response.Limits=this.getCurrentLimitsForClient();
                case 'setview'
                    this.setViewFromClient(message.view);
                case 'getview'
                    recaptureIfNeeded(this);
                    response.View=this.getCurrentViewForClient();
                case 'is2D'

                    recaptureIfNeeded(this);
                    response.is2D=is2D(this.Axes);
                case 'getNDCToDSTransform'

                    recaptureIfNeeded(this);
                    ndctods=this.computeNDC2DSTransform();
                    response.ndc2dstransform=ndctods(:);
                case 'recaptureLimitsRef'
                    recaptureLimitsRef(this);
                case 'hasMultipleTargets'
                    response=hasMultipleTargets(this);
                otherwise

                    response=process@matlab.graphics.interaction.graphicscontrol.layoutable.GridLayoutableControl(this,message);
                end
            end
        end

        function ndctods=computeNDC2DSTransform(this)
            vp=this.Axes.Camera.Viewport;
            vp.Units='devicepixels';

            outer=vp.RefFrame;
            inner=vp.Position;

            innerCenter=[inner(1)+inner(3)/2,inner(2)+inner(4)/2];
            outerCenter=[outer(1)+outer(3)/2,outer(2)+outer(4)/2];

            scale=[inner(3)/outer(3),inner(4)/outer(4),1];
            offset=[2*(innerCenter(1)-outerCenter(1))/outer(3),2*(innerCenter(2)-outerCenter(2))/outer(4),0.0];

            adjust=makehgtform('translate',offset(1),offset(2),offset(3))*makehgtform('scale',scale);
            MVPNominal=adjust*this.Axes.Camera.GetProjectionMatrix()*this.Axes.Camera.GetViewMatrix()*this.Axes.ActiveDataSpace.getMatrix();

            ndctods=inv(MVPNominal);
        end

        function limits=getCurrentLimits(this)
            limits=matlab.graphics.interaction.getDoubleAxesLimits(this.Axes);
        end

        function pboxsize=getPlotBoxSize(this)
            pboxsize=this.Axes.GetLayoutInformation.PlotBox(3:4);
        end

        function view=getView(this)
            view=this.Axes.View;
        end

        function setView(this,view)
            this.Axes.View=view;
        end

        function activeDataSpaceChanged(this)


            this.ObjectDirtyForRecapture=true;
        end

        function val=isLayoutable(this)
            val=this.Layoutable;
        end

        function updatePVPairs(this,canvas,props,vals)


            this.linkAxesControlUpdate(this.Axes,canvas);
            if~isempty(props)
                this.updateInteractionOptions(canvas);
                [props,vals]=this.addPVPair(props,vals,'containsImage',~isempty(findobj(this.Axes,'Type','image')));
                [props,vals]=this.addPVPair(props,vals,'dataAspectRatioMode',this.Axes.DataAspectRatioMode);
                this.sendPVPairsToClient(canvas,props,vals);
            end
        end




        function[props,vals]=updateInteractionOptions(this,canvas)
            this.Axes.InteractionOptions=this.Axes.InteractionOptions.updateInteractionOptions(this.Axes);
            this.Axes.InteractionOptions.sendOptionsToClient(canvas,this.Axes);
        end

        function[props,vals]=addPVPair(~,props,vals,newProperty,newValue)
            props{end+1}=newProperty;
            vals{end+1}=newValue;
        end
    end

    methods(Access=private)

        function linkAxesControlUpdate(~,ax,canvas)
            KEY='graphics_linkaxes';
            if(isappdata(ax,KEY)&&isprop(canvas,'ControlManager'))
                linkProps=getappdata(ax,KEY).LinkProp;
                if(linkProps.Enabled)
                    options='';
                    if(any(contains(linkProps.PropertyNames,'XLim')))
                        options=[options,'x'];
                    end
                    if(any(contains(linkProps.PropertyNames,'YLim')))
                        options=[options,'y'];
                    end
                    if(any(contains(linkProps.PropertyNames,'ZLim')))
                        options=[options,'z'];
                    end
                    canvas.ControlManager.linkControls(linkProps.Targets,options,'axes');
                end
            end
        end

        function recaptureIfNeeded(this)
            if(this.ObjectDirtyForRecapture)


                recaptureLimitsRef(this);
            end
            this.ObjectDirtyForRecapture=false;
        end

        function recaptureLimitsRef(this)
            import matlab.graphics.interaction.*
            this.LockedDataSpace=internal.copyDataSpace(this.Axes.ActiveDataSpace);
        end

        function limits=getCurrentLimitsForClient(this)
            if strcmp(this.Axes.ActiveDataSpace.isLinear,'on')
                limits=this.getCurrentLimits();
            else
                limits=[0,1,0,1,0,1];
            end
        end

        function setLimitsFromClient(this,limits)
            [xl,yl,zl]=UntransformLimits(this,this.LockedDataSpace,limits(1:2),limits(3:4),limits(5:6));
            if(is2D(this.Axes))
                matlab.graphics.interaction.validateAndSetLimits(this.Axes,xl,yl);
            else
                matlab.graphics.interaction.validateAndSetLimits(this.Axes,xl,yl,zl);
            end
        end

        function[xl,yl,zl]=UntransformLimits(~,ds,xlim,ylim,zlim)
            if~strcmp(ds.isLinear,'on')
                iter=matlab.graphics.axis.dataspace.XYZPointsIterator(...
                'XData',xlim,...
                'YData',ylim,...
                'ZData',zlim);
                mat=makehgtform;
                data=ds.UntransformPoints(mat,iter);
                xl=sort([data(1),data(4)]);
                yl=sort([data(2),data(5)]);
                zl=sort([data(3),data(6)]);
            else
                xl=xlim;
                yl=ylim;
                zl=zlim;
            end
        end

        function view=getCurrentViewForClient(this)
            view=this.getView();
        end

        function setViewFromClient(this,view)
            this.setView(view);
        end

        function response=hasMultipleTargets(this)
            response.multipleTargets=false;
            if isprop(this.Axes,'TargetManager')
                response.multipleTargets=(numel(this.Axes.TargetManager.Targets)>1);
            end
        end

        function sendPVPairsToClient(this,canvas,property,value)
            if isprop(canvas,'ControlManager')
                canvas.ControlManager.sendMessageToClient(this.Axes,property,value);
            end
        end
    end

end
