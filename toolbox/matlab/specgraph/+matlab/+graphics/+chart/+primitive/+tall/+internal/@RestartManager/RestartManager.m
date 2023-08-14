classdef(Sealed)RestartManager<matlab.graphics.mixin.internal.GraphicsDataTypeContainer




    properties(Constant,Access={?matlab.graphics.chart.primitive.tall.Line,...
        ?matlab.graphics.chart.primitive.tall.Scatter,...
        ?matlab.graphics.chart.primitive.Binscatter})

        ZoomXId=1
        ZoomYId=2
        PanXId=3
        PanYId=4
        ResizeXId=5
        ResizeYId=6
        ScaleXId=7
        ScaleYId=8
        LimModeXId=9
        LimModeYId=10
        DataXYId=11
    end

    properties(Access={?matlab.graphics.chart.primitive.tall.Line,...
        ?matlab.graphics.chart.primitive.tall.Scatter,...
        ?matlab.graphics.chart.primitive.Binscatter})
        AxesLimitsCache=[0,1,0,1]
        DataLimitsCache=[NaN,NaN,NaN,NaN]

        XScale matlab.internal.datatype.matlab.graphics.datatype.AxisScale='linear'
        YScale matlab.internal.datatype.matlab.graphics.datatype.AxisScale='linear'


        XLimMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        YLimMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'

        XNpixels(1,1)double{mustBeReal}
        YNpixels(1,1)double{mustBeReal}


        BinEdgesCreateFcn=@matlab.graphics.chart.primitive.tall.internal.linspaceOnAxis;



        Enabled logical{matlab.internal.validation.mustBeVector(Enabled)}=true(1,11);




        Margin=0.1;
    end

    properties(Transient,Access={?matlab.graphics.chart.primitive.tall.Line,...
        ?matlab.graphics.chart.primitive.tall.Scatter,...
        ?matlab.graphics.chart.primitive.Binscatter})
        XYDataChanged(1,1)logical=false
        InSlowAxesLimitsChange(1,1)logical=false

    end

    methods(Access={?matlab.graphics.chart.primitive.tall.Line,...
        ?matlab.graphics.chart.primitive.tall.Scatter,...
        ?matlab.graphics.chart.primitive.Binscatter})
        function obj=RestartManager(ax)
            if nargin>0
                obj=initialize(obj,ax);
            end
        end

        function obj=initialize(obj,ax)
            obj.XScale=ax.XScale;
            obj.YScale=ax.YScale;
            [axxlim,axylim]=matlab.graphics.internal.makeNumeric(ax,ax.XLim,ax.YLim);
            obj.AxesLimitsCache=[axxlim,axylim];
            obj.XLimMode=ax.XLimMode;
            obj.YLimMode=ax.YLimMode;
            PlotBox=getPlotBox(ax);
            obj.XNpixels=round(PlotBox(3));
            obj.YNpixels=round(PlotBox(4));
        end



        function[needrestart,obj,xbinedges,ybinedges,results]=check(obj,ax,...
            xbinedges,ybinedges)



            results=false(1,11);
            enabled=obj.Enabled;

            axxlim=ax.ActiveDataSpace.XLim;
            axylim=ax.ActiveDataSpace.YLim;
            if~isempty(ax)
                if~isempty(xbinedges)&&~isempty(ybinedges)
                    PlotBox=getPlotBox(ax);

                    results(obj.ResizeXId)=enabled(obj.ResizeXId)&&obj.XNpixels<round(PlotBox(3));

                    if results(obj.ResizeXId)
                        obj.XNpixels=round(PlotBox(3));
                        xbinedges=obj.BinEdgesCreateFcn(xbinedges(1),xbinedges(end),...
                        obj.XNpixels+1,obj.XScale,0);
                    end

                    results(obj.ResizeYId)=enabled(obj.ResizeYId)&&obj.YNpixels<round(PlotBox(4));
                    if results(obj.ResizeYId)
                        obj.YScale=ax.YScale;
                        obj.YNpixels=round(PlotBox(4));
                        ybinedges=obj.BinEdgesCreateFcn(ybinedges(1),ybinedges(end),...
                        obj.YNpixels+1,obj.YScale,0);
                    end



                    hAllObjs=findobj(ax,'-property','RestartManager');
                    inSlowAxesLimitsChange=false;
                    for i=1:length(hAllObjs)
                        inSlowAxesLimitsChange=inSlowAxesLimitsChange||...
                        hAllObjs(i).RestartManager.InSlowAxesLimitsChange;
                    end


                    if strcmp(ax.XLimMode,'manual')&&~inSlowAxesLimitsChange

                        results(obj.ZoomXId)=enabled(obj.ZoomXId)&&isZoomedIn(axxlim,obj.AxesLimitsCache(1:2),obj.XScale);

                        threshold=obj.Margin*diff(axxlim);
                        results(obj.PanXId)=enabled(obj.PanXId)&&((xbinedges(1)-axxlim(1)>threshold...
                        &&obj.DataLimitsCache(1)<xbinedges(1))...
                        ||(axxlim(2)-xbinedges(end)>threshold&&...
                        obj.DataLimitsCache(2)>xbinedges(end)));
                        if any(results([obj.ZoomXId,obj.PanXId]))
                            xbinedges=obj.BinEdgesCreateFcn(axxlim(1),axxlim(end),...
                            obj.XNpixels+1,obj.XScale,1);
                        end
                    end
                    if strcmp(ax.YLimMode,'manual')&&~inSlowAxesLimitsChange

                        results(obj.ZoomYId)=enabled(obj.ZoomYId)&&isZoomedIn(axylim,obj.AxesLimitsCache(3:4),obj.YScale);

                        threshold=obj.Margin*diff(axylim);
                        results(obj.PanYId)=enabled(obj.PanYId)&&((ybinedges(1)-axylim(1)>threshold...
                        &&obj.DataLimitsCache(3)<ybinedges(1))...
                        ||(axylim(2)-ybinedges(end)>threshold&&...
                        obj.DataLimitsCache(4)>ybinedges(end)));
                        if any(results([obj.ZoomYId,obj.PanYId]))
                            ybinedges=obj.BinEdgesCreateFcn(axylim(1),axylim(end),...
                            obj.YNpixels+1,obj.YScale,1);
                        end
                    end


                    results(obj.ScaleXId)=enabled(obj.ScaleXId)&&~strcmp(ax.XScale,obj.XScale);
                    if results(obj.ScaleXId)
                        obj.XScale=ax.XScale;
                        if strcmp(ax.XLimMode,'auto')
                            xbinedges=[];
                        else
                            xbinedges=obj.BinEdgesCreateFcn(axxlim(1),axxlim(end),...
                            obj.XNpixels+1,obj.XScale,1);
                        end
                    end
                    results(obj.ScaleYId)=enabled(obj.ScaleYId)&&~strcmp(ax.YScale,obj.YScale);
                    if results(obj.ScaleYId)
                        obj.YScale=ax.YScale;
                        if strcmp(ax.YLimMode,'auto')
                            ybinedges=[];
                        else
                            ybinedges=obj.BinEdgesCreateFcn(axylim(1),axylim(end),...
                            obj.YNpixels+1,obj.YScale,1);
                        end
                    end


                    results(obj.DataXYId)=enabled(obj.DataXYId)&&obj.XYDataChanged;
                    if results(obj.DataXYId)
                        obj.XYDataChanged=false;
                        if strcmp(ax.XLimMode,'auto')
                            xbinedges=[];
                        end
                        if strcmp(ax.YLimMode,'auto')
                            ybinedges=[];
                        end
                    end



                    results(obj.LimModeXId)=enabled(obj.LimModeXId)&&strcmp(obj.XLimMode,'manual')&&...
                    strcmp(ax.XLimMode,'auto');
                    if results(obj.LimModeXId)
                        xbinedges=[];
                    end


                    if~inSlowAxesLimitsChange
                        obj.XLimMode=ax.XLimMode;
                    end
                    results(obj.LimModeYId)=enabled(obj.LimModeYId)&&strcmp(obj.YLimMode,'manual')&&...
                    strcmp(ax.YLimMode,'auto');
                    if results(obj.LimModeYId)
                        ybinedges=[];
                    end
                    if~inSlowAxesLimitsChange
                        obj.YLimMode=ax.YLimMode;
                    end
                else

                    PlotBox=getPlotBox(ax);


                    results(obj.ResizeXId)=enabled(obj.ResizeXId)&&obj.XNpixels<round(PlotBox(3));

                    if results(obj.ResizeXId)
                        obj.XNpixels=round(PlotBox(3));
                        xbinedges=[];
                    end

                    results(obj.ResizeYId)=enabled(obj.ResizeYId)&&obj.YNpixels<round(PlotBox(4));
                    if results(obj.ResizeYId)
                        obj.YNpixels=round(PlotBox(4));
                        ybinedges=[];
                    end
                end
            end
            obj.AxesLimitsCache=[axxlim,axylim];
            needrestart=any(results);
        end
    end
end

function tf=isZoomedIn(newlims,oldlims,scale)



    if strcmp(scale,'log')
        tf=(diff(log10(abs(newlims))-log10(abs(oldlims))))<=-1000*max(eps(log10(abs(newlims))));
    else
        tf=(diff(newlims-oldlims))<=-1000*max(eps(newlims));
    end
end

function PlotBox=getPlotBox(ax)
    try
        PlotBox=ax.GetLayoutInformation.PlotBox;
    catch
        PlotBox=[0,0,0,0];
    end
end
