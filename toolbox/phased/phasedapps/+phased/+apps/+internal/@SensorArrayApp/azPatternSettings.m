function figOut=azPatternSettings(obj,toolStrip,figHandle,arr,w,...
    propSpeed,subarraySteerAng,freq,legendStr)






    figHandle.Name=...
    getString(message('phased:apps:arrayapp:azimuthPattern'));
    figHandle.Tag='azPatternFig';
    figHandle.HandleVisibility='on';


    set(groot,'CurrentFigure',figHandle);
    drawnow();

    if strcmp(toolStrip.TypeDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:Directivity')))
        type='Directivity';
    elseif strcmp(toolStrip.TypeDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:efield')))
        type='efield';
    elseif strcmp(toolStrip.TypeDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:Power')))
        type='power';
    elseif strcmp(toolStrip.TypeDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:PowerdB')))
        type='powerdB';
    end


    if strcmp(toolStrip.CoordDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:coordPolar')))
        coord='polar';
    elseif strcmp(toolStrip.CoordDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:coordLine')))
        coord='rectangular';
    end

    if numel(freq)>1&&~strcmp(coord,'polar')
        toolStrip.PlotStyleDropDown2DAz.Enabled=true;
    else
        toolStrip.PlotStyleDropDown2DAz.Enabled=false;
        toolStrip.PlotStyleDropDown2DAz.Value=getString(message('phased:apps:arrayapp:Overlay'));
    end

    if strcmp(toolStrip.PlotStyleDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:Overlay')))
        plotStyle='Overlay';
    else
        plotStyle='Waterfall';
    end

    if~strcmp(toolStrip.TypeDropDown2DAz.Value,getString(message('phased:apps:arrayapp:Directivity')))...
        &&isPolarizationCapable(toolStrip.AppHandle.CurrentElement)
        toolStrip.PolarizationDropDown2DAz.Enabled=true;
        toolStrip.PolarizationLabel2D.Enabled=true;
    else
        toolStrip.PolarizationDropDown2DAz.Enabled=false;
        toolStrip.PolarizationLabel2D.Enabled=false;
    end

    if~strcmp(toolStrip.TypeDropDown2DAz.Value,getString(message('phased:apps:arrayapp:Directivity')))
        toolStrip.NormalizeCheck2DAz.Enabled=true;
    else
        toolStrip.NormalizeCheck2DAz.Enabled=false;
    end

    if strcmp(toolStrip.PolarizationDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:Combined')))
        polarization='Combined';
    elseif strcmp(toolStrip.PolarizationDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:H')))
        polarization='H';
    elseif strcmp(toolStrip.PolarizationDropDown2DAz.Value,...
        getString(message('phased:apps:arrayapp:V')))
        polarization='V';
    end


    cutAng=evalin('base',toolStrip.CutAngleEditAz.Value);


    try
        if strcmp(toolStrip.SubarraySteerPopup.Value,...
            getString(message('phased:apps:arrayapp:nosubarraysteering')))
            if toolStrip.PolarizationDropDown2DAz.Enabled
                pattern(arr,freq,-180:180,cutAng,'PropagationSpeed',...
                propSpeed,'CoordinateSystem',coord,'Weights',w,'Type',type,...
                'Polarization',polarization,'Normalize',toolStrip.NormalizeCheck2DAz.Value,...
                'PlotStyle',plotStyle);
            elseif toolStrip.NormalizeCheck2DAz.Enabled
                pattern(arr,freq,-180:180,cutAng,'PropagationSpeed',...
                propSpeed,'CoordinateSystem',coord,'Weights',w,'Type',type,...
                'Normalize',toolStrip.NormalizeCheck2DAz.Value,...
                'PlotStyle',plotStyle);
            else
                pattern(arr,freq,-180:180,cutAng,'PropagationSpeed',...
                propSpeed,'CoordinateSystem',coord,'Weights',w,'Type',type,...
                'PlotStyle',plotStyle);
            end
        elseif strcmp(toolStrip.SubarraySteerPopup.Value,...
            getString(message('phased:apps:arrayapp:customsubarraysteering')))
            if toolStrip.PolarizationDropDown2DAz.Enabled
                pattern(arr,freq,-180:180,cutAng,'PropagationSpeed',...
                propSpeed,'CoordinateSystem',coord,'Weights',w,...
                'ElementWeights',obj.ElementWeights,'Type',type,...
                'Polarization',polarization,...
                'Normalize',toolStrip.NormalizeCheck2DAz.Value,...
                'PlotStyle',plotStyle);
            elseif toolStrip.NormalizeCheck2DAz.Enabled
                pattern(arr,freq,-180:180,cutAng,'PropagationSpeed',...
                propSpeed,'CoordinateSystem',coord,'Weights',w,...
                'ElementWeights',obj.ElementWeights,'Type',type,...
                'Normalize',toolStrip.NormalizeCheck2DAz.Value,...
                'PlotStyle',plotStyle);
            else
                pattern(arr,freq,-180:180,cutAng,'PropagationSpeed',...
                propSpeed,'CoordinateSystem',coord,'Weights',w,...
                'ElementWeights',obj.ElementWeights,'Type',type,...
                'PlotStyle',plotStyle);
            end
        else
            if toolStrip.PolarizationDropDown2DAz.Enabled
                pattern(arr,freq,-180:180,cutAng,'PropagationSpeed',...
                propSpeed,'CoordinateSystem',coord,'Weights',w,...
                'SteerAngle',subarraySteerAng,'Type',type,...
                'Polarization',polarization,...
                'Normalize',toolStrip.NormalizeCheck2DAz.Value,...
                'PlotStyle',plotStyle);
            elseif toolStrip.NormalizeCheck2DAz.Enabled
                pattern(arr,freq,-180:180,cutAng,'PropagationSpeed',...
                propSpeed,'CoordinateSystem',coord,'Weights',w,...
                'SteerAngle',subarraySteerAng,'Type',type,...
                'Normalize',toolStrip.NormalizeCheck2DAz.Value,...
                'PlotStyle',plotStyle);
            else
                pattern(arr,freq,-180:180,cutAng,'PropagationSpeed',...
                propSpeed,'CoordinateSystem',coord,'Weights',w,...
                'SteerAngle',subarraySteerAng,'Type',type,...
                'PlotStyle',plotStyle);
            end
        end
    catch
    end
    figHandle.HandleVisibility='off';


    if strcmp(coord,'polar')
        polariHandle=findall(figHandle,'Tag','PolariObject');
        polariData=polariHandle.UserData;
        polariData.LegendLabels=legendStr;
        polariData.hLegend.Location='southeast';


        polariData.hLegend.Position=[0.5722,0.0256,0.4102,0.0529];
        axtoolbar(figHandle.CurrentAxes,{'export'});
    else
        hAxes=figHandle.CurrentAxes;
        if strcmp(plotStyle,'Overlay')
            legend(hAxes,legendStr,'Location','southeast',...
            'AutoUpdate','off','UIContextMenu',[])
        end

        if strcmp(plotStyle,'Waterfall')
            axtoolbar(figHandle.CurrentAxes,{'export','rotate','datacursor',...
            'pan','zoomin','zoomout','restoreview'});
        else
            axtoolbar(figHandle.CurrentAxes,{'export','datacursor',...
            'pan','zoomin','zoomout','restoreview'});
        end
    end

    figOut=figHandle;