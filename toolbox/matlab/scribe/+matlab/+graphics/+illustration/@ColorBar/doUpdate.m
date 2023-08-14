function doUpdate(hObj,us)





    axisLocation=[];
    switch hObj.Location
    case 'eastoutside'
        axisLocation='out';
    case 'east'
        axisLocation='in';
    case 'westoutside'
        axisLocation='out';
    case 'west'
        axisLocation='in';
    case 'northoutside'
        axisLocation='out';
    case 'north'
        axisLocation='in';
    case 'southoutside'
        axisLocation='out';
    case 'south'
        axisLocation='in';
    case 'manual'




    end


    orientation=[];
    if~isempty(hObj.Parent)&&...
        isa(hObj.Parent,'matlab.graphics.layout.TiledChartLayout')&&...
        ~isempty(hObj.Layout)
        switch hObj.Layout.Tile
        case 'north'
            axisLocation='out';
            orientation='horizontal';
        case 'east'
            axisLocation='out';
            orientation='vertical';
        case 'south'
            axisLocation='out';
            orientation='horizontal';
        case 'west'
            axisLocation='out';
            orientation='vertical';
        end

        if~isempty(orientation)
            hObj.Orientation=orientation;
        end
    end
    if~isempty(axisLocation)&&strcmp(hObj.AxisLocationMode,'auto')
        hObj.AxisLocation_I=axisLocation;
    end


    localSetupRuler(hObj);

    reference_clim=[0,1];
    if~isempty(hObj.Axes)
        if~strcmp(hObj.CDataMapping_I,'none')&&strcmp(hObj.CDataMappingMode,'auto')
            mapping=matlab.graphics.illustration.ColorBar.determine_cdatamapping(hObj.Axes);
            if~strcmp(mapping,'none')&&~strcmp(mapping,'mixed')
                hObj.CDataMapping_I=mapping;
            end
        end
        reference_clim=matlab.graphics.illustration.ColorBar.determine_range(hObj.Axes,hObj.CDataMapping);
    end


    if strcmp(hObj.LimitsMode,'auto')


        hObj.Limits_I=reference_clim;
        cmin=0;
        cmax=1;
    elseif hObj.ScaleColormapWithLimits



        cbar_clim=hObj.Limits_I;
        cmin=(cbar_clim(1)-reference_clim(1))/(reference_clim(2)-reference_clim(1));
        cmax=(cbar_clim(2)-reference_clim(1))/(reference_clim(2)-reference_clim(1));
    else



        cmin=0;
        cmax=1;
    end


    switch hObj.Orientation_I
    case 'vertical'

        if isvalid(hObj.Face)
            hObj.Face.ColorData=single([cmin,cmin,cmax,cmax]);
        end


        if isvalid(hObj.Ruler)&&~isempty(hObj.Ruler.Label_I)
            if strcmp(hObj.Ruler.Label_I.RotationMode,'auto')
                hObj.Ruler.Label_I.Rotation_I=90;
            end
        end




        hObj.DataSpace.YDir=hObj.Direction;
        hObj.Ruler.Direction=hObj.Direction;
        hObj.DataSpace.XDir='normal';


        hObj.DataSpace.XLim=[0,1];
        if strcmp(hObj.LimitsMode,'auto')&&~isempty(hObj.Axes)
            hObj.Limits_I=matlab.graphics.illustration.ColorBar.determine_range(hObj.Axes,hObj.CDataMapping);
        end
        hObj.DataSpace.YLim=hObj.Limits_I;

        if strcmp(hObj.Ruler.ScaleMode,'auto')&&strcmp(hObj.DataSpace.YScaleMode,'auto')

            if(~isempty(hObj.Axes))
                hObj.Ruler.Scale_I=hObj.Axes.ColorScale;
                hObj.DataSpace.YScale_I=hObj.Axes.ColorScale;
            else
                hObj.Ruler.Scale_I='linear';
                hObj.DataSpace.YScale_I='linear';
            end
        end
        if strcmp(hObj.DataSpace.XScaleMode,'auto')
            hObj.DataSpace.XScale_I='linear';
        end

    case 'horizontal'

        if isvalid(hObj.Face)
            hObj.Face.ColorData=single([cmin,cmax,cmax,cmin]);
        end


        if isvalid(hObj.Ruler)&&~isempty(hObj.Ruler.Label_I)
            if strcmp(hObj.Ruler.Label_I.RotationMode,'auto')
                hObj.Ruler.Label_I.Rotation_I=0;
            end
        end




        hObj.DataSpace.YDir='normal';
        hObj.DataSpace.XDir=hObj.Direction;
        hObj.Ruler.Direction=hObj.Direction;


        hObj.DataSpace.YLim=[0,1];
        if strcmp(hObj.LimitsMode,'auto')&&~isempty(hObj.Axes)
            hObj.Limits_I=matlab.graphics.illustration.ColorBar.determine_range(hObj.Axes,hObj.CDataMapping);
        end
        hObj.DataSpace.XLim=hObj.Limits_I;

        if strcmp(hObj.Ruler.ScaleMode,'auto')&&strcmp(hObj.DataSpace.XScaleMode,'auto')

            if(~isempty(hObj.Axes))
                hObj.Ruler.Scale_I=hObj.Axes.ColorScale;
                hObj.DataSpace.XScale_I=hObj.Axes.ColorScale;
            else
                hObj.Ruler.Scale_I='linear';
                hObj.DataSpace.XScale_I='linear';
            end
        end
        if strcmp(hObj.DataSpace.YScaleMode,'auto')
            hObj.DataSpace.YScale_I='linear';
        end

    end

    if~isempty(hObj.Axes)

        if strcmp(hObj.ColormapMode,'auto')
            hObj.Colormap_I=hObj.Axes.ColorSpace.Colormap;
        end


        if strcmp(hObj.Visible,'on')
            if isvalid(hObj.Face)
                img=hObj.Colormap;
                if isempty(img)
                    img=[1,1,1];
                end
                tmp=zeros([4,size(img,1)],'uint8');
                if isa(img,'uint8')
                    coeff=1;
                else
                    coeff=255;
                end
                tmp(1,:)=coeff*img(:,1);
                tmp(2,:)=coeff*img(:,2);
                tmp(3,:)=coeff*img(:,3);
                tmp(4,:)=255;

                if strcmp(hObj.Direction,'reverse')
                    tmp=fliplr(tmp);
                end
                hObj.Face.Texture.CData=tmp;
            end
        end


        matlab.graphics.illustration.colorbar.updateColorbarFontProperties(hObj,hObj.Axes);
    end



    if isvalid(hObj.Title)
        if strcmp(hObj.Title.FontNameMode,'auto')
            hObj.Title.FontName_I=hObj.FontName;
        end

        if strcmp(hObj.Title.FontAngleMode,'auto')
            hObj.Title.FontAngle_I=hObj.FontAngle;
        end

        if strcmp(hObj.Title.FontSizeMode,'auto')
            oldFontUnits=hObj.Title.FontUnits_I;
            hObj.Title.FontUnits_I='points';
            hObj.Title.FontSize_I=hObj.FontSize_I;
            hObj.Title.FontUnits_I=oldFontUnits;
        end

        if strcmp(hObj.Title.FontWeightMode,'auto')
            hObj.Title.FontWeight_I=hObj.FontWeight;
        end









        updateTitlePosition=strcmp(hObj.Title.PositionMode,'auto');
        if updateTitlePosition
            vp=hObj.Camera.Viewport;
            vp.Units='points';
            cbPointsPos=vp.Position;
            if isvalid(hObj.Ruler)
                rulerFontSize=hObj.Ruler.FontSize_I;



                if strcmp(hObj.RulerLocation_I,'top')
                    offset=2*rulerFontSize;
                else
                    offset=.35*rulerFontSize;
                end


                newXPointsPos=cbPointsPos(3)/2;
                newYPointsPos=cbPointsPos(4)+offset;
                titlePointsPos=[newXPointsPos,newYPointsPos,0];
                hObj.Title.Position_I=titlePointsPos;
            end
        end
    end


    if~isempty(hObj.Axes)
        matlab.graphics.illustration.internal.updateLegendMenuToolbar([],[],hObj);
    end


    if~isempty(hObj.Parent)
        tickLen=hObj.TickLength;
        if isvalid(hObj.Ruler)
            hObj.Ruler.TickLength=[tickLen,0];
        end
    end


    if isvalid(hObj.Face)&&strcmp(hObj.Face.VisibleMode,'auto')
        hObj.Face.Visible_I=hObj.Visible;
    end
    if isvalid(hObj.Ruler)&&strcmp(hObj.Ruler.VisibleMode,'auto')
        hObj.Ruler.Visible_I=hObj.Visible;
    end


    if isvalid(hObj.SelectionHandle)
        if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
            hObj.SelectionHandle.Visible='on';
        else
            hObj.SelectionHandle.Visible='off';
        end
    end

    fig=ancestor(hObj,'figure');


    if~isempty(fig)&&...
        ~matlab.internal.editor.figure.FigureUtils.isEditorEmbeddedFigure(fig)&&...
        ~matlab.internal.editor.figure.FigureUtils.isEditorSnapshotFigure(fig)


        setappdata(hObj,'inUpdate',true);



        if isappdata(hObj,'RepairUICOnLoad')

            rmappdata(hObj,'RepairUICOnLoad');
            doMethod(hObj,'repairContextMenu',hObj.UIContextMenu,fig);
        end



        uic=hObj.UIContextMenu;
        if~isempty(uic)&&~isequal(uic.Parent,fig)



            uic.Parent=[];
            uic.Parent=fig;
        end

        rmappdata(hObj,'inUpdate')
    end













    function axisLocation=localDetermineAxisLocation(hObj)



        axisLocation=[];
        switch hObj.Location_I
        case{'east','eastoutside'}
            if strcmp(hObj.RulerLocation_I,'right')
                axisLocation='out';
            else
                axisLocation='in';
            end
        case{'west','westoutside'}
            if strcmp(hObj.RulerLocation_I,'left')
                axisLocation='out';
            else
                axisLocation='in';
            end
        case{'north','northoutside'}
            if strcmp(hObj.RulerLocation_I,'top')
                axisLocation='out';
            else
                axisLocation='in';
            end
        case{'south','southoutside'}
            if strcmp(hObj.RulerLocation_I,'bottom')
                axisLocation='out';
            else
                axisLocation='in';
            end
        case 'manual'


            hFig=ancestor(hObj,'figure');
            hAx=hObj.Axes;
            if isvalid(hFig)&&isvalid(hAx)

                hContainer=ancestor(hObj,'matlab.ui.internal.mixin.CanvasHostMixin','node');
                cbPosPixels=hgconvertunits(hFig,hObj.Position_I,hObj.Units_I,'pixels',hContainer);

                if isa(hObj.Parent,'matlab.graphics.layout.Layout')
                    axPlotBoxPixels=hgconvertunits(hFig,hAx.InnerPosition_I,hAx.Units_I,'pixels',hContainer);
                else
                    axPlotBoxPixels=hAx.PlotBox;
                end

                cbCenter=[cbPosPixels(1)+cbPosPixels(3)/2,cbPosPixels(2)+cbPosPixels(4)/2];
                axCenter=[axPlotBoxPixels(1)+axPlotBoxPixels(3)/2,axPlotBoxPixels(2)+axPlotBoxPixels(4)/2];
                rulerLoc=hObj.RulerLocation_I;

                switch hObj.Orientation_I
                case 'vertical'
                    if cbCenter(1)>axCenter(1)
                        if strcmp(rulerLoc,'left')
                            axisLocation='in';
                        else
                            axisLocation='out';
                        end
                    else
                        if strcmp(rulerLoc,'right')
                            axisLocation='in';
                        else
                            axisLocation='out';
                        end
                    end
                case 'horizontal'
                    if cbCenter(2)>axCenter(2)
                        if strcmp(rulerLoc,'bottom')
                            axisLocation='in';
                        else
                            axisLocation='out';
                        end
                    else
                        if strcmp(rulerLoc,'top')
                            axisLocation='in';
                        else
                            axisLocation='out';
                        end
                    end
                end
            end
        end
        assert(~isempty(axisLocation),'axisLocation should not be empty');

        function tf=localIsValidRulerLocation(hObj)

            tf=false;
            switch hObj.Orientation_I
            case 'horizontal'
                tf=ismember(hObj.RulerLocation_I,{'top','bottom'});
            case 'vertical'
                tf=ismember(hObj.RulerLocation_I,{'left','right'});
            end


            function rulerLocation=localDetermineRulerLocation(hObj)



                rulerLocation=[];
                switch hObj.Location_I
                case{'east','eastoutside'}
                    if strcmp(hObj.AxisLocation_I,'out')
                        rulerLocation='right';
                    else
                        rulerLocation='left';
                    end
                case{'west','westoutside'}
                    if strcmp(hObj.AxisLocation_I,'out')
                        rulerLocation='left';
                    else
                        rulerLocation='right';
                    end
                case{'north','northoutside'}
                    if strcmp(hObj.AxisLocation_I,'out')
                        rulerLocation='top';
                    else
                        rulerLocation='bottom';
                    end
                case{'south','southoutside'}
                    if strcmp(hObj.AxisLocation_I,'out')
                        rulerLocation='bottom';
                    else
                        rulerLocation='top';
                    end
                case 'layout'
                    if~isempty(hObj.Parent)&&...
                        isa(hObj.Parent,'matlab.graphics.layout.TiledChartLayout')&&...
                        ~isempty(hObj.Layout)
                        if strcmp(hObj.Layout.Tile,'north')
                            rulerLocation='top';
                        elseif strcmp(hObj.Layout.Tile,'west')
                            rulerLocation='left';
                        elseif strcmp(hObj.Layout.Tile,'south')
                            rulerLocation='bottom';
                        else
                            rulerLocation='right';
                        end
                    end
                case 'manual'


                    hFig=ancestor(hObj,'figure');
                    hAx=hObj.Axes;
                    if isvalid(hFig)&&~isempty(hAx)&&isvalid(hAx)

                        hContainer=ancestor(hObj,'matlab.ui.internal.mixin.CanvasHostMixin','node');
                        cbPosPixels=hgconvertunits(hFig,hObj.Position_I,hObj.Units_I,'pixels',hContainer);

                        if isa(hObj.Parent,'matlab.graphics.layout.Layout')
                            axPlotBoxPixels=hgconvertunits(hFig,hAx.InnerPosition_I,hAx.Units_I,'pixels',hContainer);
                        else
                            axPlotBoxPixels=hAx.PlotBox;
                        end

                        cbCenter=[cbPosPixels(1)+cbPosPixels(3)/2,cbPosPixels(2)+cbPosPixels(4)/2];
                        axCenter=[axPlotBoxPixels(1)+axPlotBoxPixels(3)/2,axPlotBoxPixels(2)+axPlotBoxPixels(4)/2];

                        axisLoc=hObj.AxisLocation_I;
                        switch hObj.Orientation_I
                        case 'vertical'
                            if cbCenter(1)>axCenter(1)
                                if strcmp(axisLoc,'in')
                                    rulerLocation='left';
                                else
                                    rulerLocation='right';
                                end
                            else
                                if strcmp(axisLoc,'in')
                                    rulerLocation='right';
                                else
                                    rulerLocation='left';
                                end
                            end
                        case 'horizontal'
                            if cbCenter(2)>axCenter(2)
                                if strcmp(axisLoc,'in')
                                    rulerLocation='bottom';
                                else
                                    rulerLocation='top';
                                end
                            else
                                if strcmp(axisLoc,'in')
                                    rulerLocation='top';
                                else
                                    rulerLocation='bottom';
                                end
                            end
                        end
                    end
                end


                if isempty(rulerLocation)
                    rulerLocation=hObj.RulerLocation_I;
                end
                assert(~isempty(rulerLocation),'rulerLocation should not be empty');

                function localSetupRuler(hObj)


                    rulerLocation=localDetermineRulerLocation(hObj);
                    if strcmp(hObj.RulerLocationMode,'auto')
                        hObj.RulerLocation_I=rulerLocation;
                    else












                        if~localIsValidRulerLocation(hObj)
                            warning(message('MATLAB:colorbar:InvalidRulerLocation',hObj.RulerLocation_I,hObj.Orientation_I));
                            hObj.RulerLocation_I=rulerLocation;
                        else



                            axisLocation=localDetermineAxisLocation(hObj);
                            hObj.AxisLocation=axisLocation;
                        end



                        hObj.RulerLocationMode='auto';
                    end


                    rulerLocation=hObj.RulerLocation_I;
                    switch rulerLocation
                    case 'left'

                        hObj.Ruler.Axis=1;
                        hObj.Ruler.FirstCrossoverAxis=0;
                        hObj.Ruler.FirstCrossoverValue=-inf;
                    case 'right'

                        hObj.Ruler.Axis=1;
                        hObj.Ruler.FirstCrossoverAxis=0;
                        hObj.Ruler.FirstCrossoverValue=inf;
                    case 'top'

                        hObj.Ruler.Axis=0;
                        hObj.Ruler.FirstCrossoverAxis=1;
                        hObj.Ruler.FirstCrossoverValue=inf;
                    case 'bottom'

                        hObj.Ruler.Axis=0;
                        hObj.Ruler.FirstCrossoverAxis=1;
                        hObj.Ruler.FirstCrossoverValue=-inf;
                    otherwise

                    end
