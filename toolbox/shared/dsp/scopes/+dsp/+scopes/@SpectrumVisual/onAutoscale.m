function onAutoscale(this,auto)




    if auto

        dirtyState=getDirtyStatus(this);
        c=onCleanup(@()restoreDirtyStatus(this,dirtyState));
    end
    if~isCCDFMode(this)&&this.Axes(1,1)~=-1
        if isSpectrogramMode(this)
            newYLim=get(this.Axes(1,2),'CLim');
            setPropertyValue(this,'MinColorLim',sprintf('%.20g',newYLim(1)),...
            'MaxColorLim',sprintf('%.20g',newYLim(2)),true);
            updateColorBar(this);
        elseif isCombinedViewMode(this)

            newYLim=get(this.Axes(1,1),'YLim');
            setPropertyValue(this,'MinYLim',sprintf('%.20g',newYLim(1)),...
            'MaxYLim',sprintf('%.20g',newYLim(2)),true);

            newCLim=get(this.Axes(1,2),'CLim');
            setPropertyValue(this,'MinColorLim',sprintf('%.20g',newCLim(1)),...
            'MaxColorLim',sprintf('%.20g',newCLim(2)),true);
            updateColorBar(this);
        else
            newYLim=get(this.Axes(1,1),'YLim');
            setPropertyValue(this,'MinYLim',sprintf('%.20g',newYLim(1)),...
            'MaxYLim',sprintf('%.20g',newYLim(2)),true);
        end
        this.UserGeneratedYLimChange=~auto;
        sendEvent(this.Application,'VisualLimitsChanged');
    end
    this.UserGeneratedYLimChange=true;
end
