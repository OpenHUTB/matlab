function setCCDFMode(this,enable)




    hPlotter=this.Plotter;

    if~isempty(hPlotter)
        hPlotNav=getExtInst(this.Application,'Tools','Plot Navigation');
        if~isCCDFMode(this)&&~isempty(hPlotNav)
            this.PlotNavigationSettings=struct(...
            'XDataDisplay',getPropertyValue(hPlotNav,'XDataDisplay'),...
            'YDataDisplay',getPropertyValue(hPlotNav,'YDataDisplay'),...
            'AutoscaleSecondaryAxes',getPropertyValue(hPlotNav,'AutoscaleSecondaryAxes'),...
            'AutoscaleXAnchor',getPropertyValue(hPlotNav,'AutoscaleXAnchor'),...
            'AutoscaleYAnchor',getPropertyValue(hPlotNav,'AutoscaleYAnchor'));
        end

        if~enable
            this.CurrentCCDFDistribution=[];
        end

        this.CCDFModeEnable=enable;
        if isFrequencyInputMode(this)
            hPlotter.CCDFMode=false;
            return;
        end
        hPlotter.CCDFMode=enable;

        editOptions(this.Application.ExtDriver,this,false);

        if~isempty(this.Application.DataSource)
            if isDataEmpty(this.Application.DataSource)
                return;
            end
            resetDataBuffer(this.Application.DataSource);
        end

        if~isempty(hPlotNav)
            pns=this.PlotNavigationSettings;
            if enable
                setPropertyValue(hPlotNav,'XDataDisplay',90);
                setPropertyValue(hPlotNav,'YDataDisplay',100);
                setPropertyValue(hPlotNav,'AutoscaleSecondaryAxes',true);
                setPropertyValue(hPlotNav,'AutoscaleXAnchor','left');
                setPropertyValue(hPlotNav,'AutoscaleYAnchor','top');
                setPropertyValue(hPlotNav,'AutoscaleYAnchor','top');
                if enable
                    updateView(this,'CCDF','Spectrum');
                else
                    updateView(this);
                end
            else
                if enable
                    updateView(this,'CCDF','Spectrum');
                else
                    updateView(this);
                end
                setPlotNavigationProperty(this,hPlotNav,pns,'XDataDisplay',100);
                setPlotNavigationProperty(this,hPlotNav,pns,'YDataDisplay',80);
                setPlotNavigationProperty(this,hPlotNav,pns,'AutoscaleSecondaryAxes',false);
                setPlotNavigationProperty(this,hPlotNav,pns,'AutoscaleXAnchor','center');
                setPlotNavigationProperty(this,hPlotNav,pns,'AutoscaleYAnchor','center');
            end
        end
        isScopeLocked=isSourceRunning(this);
        if isScopeLocked
            validFlag=validateCurrentSettings(this);
            if validFlag
                localUpdate(this,false,false,true);
            end
        else
            removeDataAndReadoutsAndAddMessage(this);
        end
    else
        this.CCDFModeEnable=false;
    end
end
