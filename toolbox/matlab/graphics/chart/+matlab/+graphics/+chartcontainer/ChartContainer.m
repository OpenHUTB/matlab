classdef ChartContainer<matlab.graphics.chart.internal.ChartBaseProxy





    methods(Access=protected)

        function ax=createAxes(obj)
            ax=matlab.graphics.axis.Axes.empty;
            tl=obj.getLayout;
            if isempty(tl.Children)
                ax=matlab.graphics.axis.Axes('Parent',tl);
            end
        end
    end

    methods(Sealed,Access={?matlab.graphics.chart.Chart,?matlab.graphics.chart.internal.PositionalbleChartWithAxes})

        function tl=getLayout(obj)

            tl=findobj(obj.NodeChildren,'-depth',0,'-class','matlab.graphics.layout.TiledChartLayout');
            if isempty(tl)
                tl=matlab.graphics.layout.TiledChartLayout('Parent',obj);
            end
        end
    end

    methods(Access=protected)
        function obj=ChartContainer(varargin)
            obj=obj@matlab.graphics.chart.internal.ChartBaseProxy(varargin{:});
            obj=obj.doSetupInternal;
        end

        function obj=doSetupInternal(obj)
            obj.SetupUpdateBlock=true;


            obj.Type_I=lower(class(obj));


            ax=obj.getLayout;

            currentFig=ancestor(obj,'figure');
            currentax=[];
            if obj.useGcaBehavior&&~isempty(currentFig)
                currentax=currentFig.CurrentAxes;
            end

            try
                obj.setup;

                if~isvalid(obj)
                    msgid='CAF:ChartDestroyed';
                    errmsg='Chart object destroyed or corrupted in setup.';
                    error(msgid,errmsg);
                end
            catch ex

                if~isempty(currentax)
                    currentFig.CurrentAxes=currentax;
                end
                rethrow(ex);
            end

            if~isempty(obj.CtorArgs(:))
                matlab.graphics.chart.internal.ctorHelper(obj,obj.CtorArgs);
            end


            if~isempty(currentax)&&isvalid(currentax)
                currentFig.CurrentAxes=currentax;
            end


            if obj.useGcaBehavior
                fig=ancestor(obj,'figure');
                if isscalar(fig)
                    fig.CurrentAxes=obj;
                end
            end

            MarkDirty(obj,'chart');

            obj.HandleVisibilitySetListener=addlistener(obj,...
            'HandleVisibility','PostSet',@(o,e)warnOnHandleVisibilitySetListener(o,e));

            obj.SetupUpdateBlock=false;

        end
    end

    properties(Access=private,Transient,NonCopyable,UsedInUpdate=false)
        HandleVisibilitySetListener;
    end

    methods(Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden)
        function hCopy=copyElement(hSrc)





            matlab.graphics.chart.internal.ChartBaseProxy.chartObjectBeingCopied(true);
            c=onCleanup(@()matlab.graphics.chart.internal.ChartBaseProxy.chartObjectBeingCopied(false));


            hCopy=copyElement@matlab.graphics.chart.internal.ChartBaseProxy(hSrc);
        end
    end



    methods(Access=protected)
        function unitPos=getUnitPositionObject(hObj)





            tl=hObj.getLayout;
            hAx=findall(tl,'-isa','matlab.graphics.axis.AbstractAxes');
            if isa(hAx,'matlab.graphics.axis.AbstractAxes')&&~isempty(hAx)
                unitPos=hAx(1).Camera.Viewport;
            else

                unitPos=matlab.graphics.general.UnitPosition;


                hCanvas=ancestor(hObj,'matlab.graphics.primitive.canvas.Canvas','node');
                if isscalar(hCanvas)
                    characterSize=hCanvas.getCharacterSize();
                    unitPos.ScreenResolution=hCanvas.ScreenPixelsPerInch;
                    unitPos.RefFrame=hCanvas.ReferenceViewport;
                    unitPos.CharacterWidth=characterSize(1);
                    unitPos.CharacterHeight=characterSize(2);
                end
            end
        end
    end

    methods
        function c=getFocusableChildren(obj)



            l=obj.getLayout();
            c=l.getFocusableChildren();
        end
    end
end



function warnOnHandleVisibilitySetListener(~,e)
    if isa(e.AffectedObject,'matlab.graphics.chartcontainer.ChartContainer')
        if~strcmp(e.AffectedObject.HandleVisibility,'on')
            e.AffectedObject.HandleVisibility='on';
            warning(message('MATLAB:graphics:chart:HandleVisibilityMustBeOn'));
        end
    end
end

