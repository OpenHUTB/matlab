function updateYAxisLimits(this)





    hAxes=this.Axes(1,1);
    if ishghandle(hAxes)
        if strcmp(get(hAxes,'YScale'),'log')
            l=this.LimitListener;
            uiservices.setListenerEnable(l,false);
            set(hAxes(1,1),'YLim',[0.0001,100]);
            uiservices.setListenerEnable(l,true);
        else
            try
                newYLim=[evalPropertyValue(this,'MinYLim'),evalPropertyValue(this,'MaxYLim')];
                l=this.LimitListener;
                uiservices.setListenerEnable(l,false);
                set(hAxes(1,1),'YLim',newYLim);
                uiservices.setListenerEnable(l,true);
            catch ME
                oldLimits=get(hAxes(1,1),'YLim');
                uiscopes.errorHandler(uiscopes.message('CannotEvaluateYLims',...
                ME.message,oldLimits(1),oldLimits(2)));
            end
        end
        sendEvent(this.Application,'VisualLimitsChanged');
    end
end
