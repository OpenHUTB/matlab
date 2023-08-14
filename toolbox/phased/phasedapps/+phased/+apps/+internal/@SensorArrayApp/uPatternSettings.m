function figOut=uPatternSettings(obj,toolStrip,figHandle,arr,w,...
    propSpeed,subarraySteerAng,freq,legendStr)





    figHandle.Name=getString(message('phased:apps:arrayapp:uPattern'));
    figHandle.Tag='uPatternFig';
    figHandle.HandleVisibility='on';

    set(groot,'CurrentFigure',figHandle);
    drawnow();

    if strcmp(toolStrip.TypeDropDownUV.Value,...
        getString(message('phased:apps:arrayapp:Directivity')))
        type='Directivity';
    elseif strcmp(toolStrip.TypeDropDownUV.Value,...
        getString(message('phased:apps:arrayapp:efield')))
        type='efield';
    elseif strcmp(toolStrip.TypeDropDownUV.Value,...
        getString(message('phased:apps:arrayapp:Power')))
        type='power';
    else
        type='powerdB';
    end

    if numel(freq)>1
        toolStrip.PlotStyleDropDownUV.Enabled=true;
    else
        toolStrip.PlotStyleDropDownUV.Enabled=false;
        toolStrip.PlotStyleDropDownUV.Value=getString(message('phased:apps:arrayapp:Overlay'));
    end

    if strcmp(toolStrip.PlotStyleDropDownUV.Value,...
        getString(message('phased:apps:arrayapp:Overlay')))
        plotStyle='Overlay';
    else
        plotStyle='Waterfall';
    end

    if~strcmp(toolStrip.TypeDropDownUV.Value,getString(message('phased:apps:arrayapp:Directivity')))...
        &&isPolarizationCapable(toolStrip.AppHandle.CurrentElement)
        toolStrip.PolarizationDropDownUV.Enabled=true;
        toolStrip.PolarizationLabelUV.Enabled=true;
    else
        toolStrip.PolarizationDropDownUV.Enabled=false;
        toolStrip.PolarizationLabelUV.Enabled=false;
    end

    if~strcmp(toolStrip.TypeDropDownUV.Value,getString(message('phased:apps:arrayapp:Directivity')))
        toolStrip.NormalizeCheckUV.Enabled=true;
    else
        toolStrip.NormalizeCheckUV.Enabled=false;
    end

    if strcmp(toolStrip.PolarizationDropDownUV.Value,...
        getString(message('phased:apps:arrayapp:Combined')))
        polarization='Combined';
    elseif strcmp(toolStrip.PolarizationDropDownUV.Value,...
        getString(message('phased:apps:arrayapp:H')))
        polarization='H';
    else
        polarization='V';
    end


    if strcmp(toolStrip.SubarraySteerPopup.Value,...
        getString(message('phased:apps:arrayapp:nosubarraysteering')))
        if toolStrip.PolarizationDropDownUV.Enabled
            pattern(arr,freq,-1:0.01:1,0,'CoordinateSystem','UV',...
            'PropagationSpeed',propSpeed,'Weights',w,'Type',type,...
            'Polarization',polarization,'Normalize',toolStrip.NormalizeCheckUV.Value,...
            'PlotStyle',plotStyle);
        elseif toolStrip.NormalizeCheckUV.Enabled
            pattern(arr,freq,-1:0.01:1,0,'CoordinateSystem','UV',...
            'PropagationSpeed',propSpeed,'Weights',w,'Type',type,...
            'Normalize',toolStrip.NormalizeCheckUV.Value,...
            'PlotStyle',plotStyle);
        else
            pattern(arr,freq,-1:0.01:1,0,'CoordinateSystem','UV',...
            'PropagationSpeed',propSpeed,'Weights',w,'Type',type);
        end

    elseif strcmp(toolStrip.SubarraySteerPopup.Value,...
        getString(message('phased:apps:arrayapp:customsubarraysteering')))
        if toolStrip.PolarizationDropDownUV.Enabled
            pattern(arr,freq,-1:0.01:1,0,'CoordinateSystem','UV',...
            'PropagationSpeed',propSpeed,'Weights',w,...
            'ElementWeights',obj.ElementWeights,'Type',type,...
            'Polarization',polarization,'Normalize',toolStrip.NormalizeCheckUV.Value,...
            'PlotStyle',plotStyle);
        elseif toolStrip.NormalizeCheckUV.Enabled
            pattern(arr,freq,-1:0.01:1,0,'CoordinateSystem','UV',...
            'PropagationSpeed',propSpeed,'Weights',w,...
            'ElementWeights',obj.ElementWeights,'Type',type,...
            'Normalize',toolStrip.NormalizeCheckUV.Value,...
            'PlotStyle',plotStyle);
        else
            pattern(arr,freq,-1:0.01:1,0,'CoordinateSystem','UV',...
            'PropagationSpeed',propSpeed,'Weights',w,...
            'ElementWeights',obj.ElementWeights,'Type',type);
        end
    else
        if toolStrip.PolarizationDropDownUV.Enabled
            pattern(arr,freq,-1:0.01:1,0,'CoordinateSystem','UV',...
            'PropagationSpeed',propSpeed,'Weights',w,...
            'SteerAngle',subarraySteerAng,'Type',type,...
            'Polarization',polarization,'Normalize',toolStrip.NormalizeCheckUV.Value,...
            'PlotStyle',plotStyle);
        elseif toolStrip.NormalizeCheckUV.Enabled
            pattern(arr,freq,-1:0.01:1,0,'CoordinateSystem','UV',...
            'PropagationSpeed',propSpeed,'Weights',w,...
            'SteerAngle',subarraySteerAng,'Type',type,...
            'Normalize',toolStrip.NormalizeCheckUV.Value,...
            'PlotStyle',plotStyle);
        else
            pattern(arr,freq,-1:0.01:1,0,'CoordinateSystem','UV',...
            'PropagationSpeed',propSpeed,'Weights',w,...
            'SteerAngle',subarraySteerAng,'Type',type);
        end
    end

    figHandle.HandleVisibility='off';


    hAxes=figHandle.CurrentAxes;
    if strcmp(plotStyle,'Overlay')
        legend(hAxes,legendStr,'Location','southeast',...
        'AutoUpdate','off','UIContextMenu',[]);
    end

    if strcmp(plotStyle,'waterfall')
        axtoolbar(figHandle.CurrentAxes,{'export','rotate','datacursor',...
        'pan','zoomin','zoomout','restoreview'});
    else
        axtoolbar(figHandle.CurrentAxes,{'export','datacursor',...
        'pan','zoomin','zoomout','restoreview'});
    end

    figOut=figHandle;