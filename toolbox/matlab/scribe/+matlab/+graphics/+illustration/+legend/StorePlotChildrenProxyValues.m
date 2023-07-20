function StorePlotChildrenProxyValues(object)




    ax=ancestor(object,'matlab.graphics.axis.AbstractAxes','node');
    if~isempty(ax)&&isvalid(ax)
        axesHasLegend=~isempty(ax.Legend)&&isvalid(ax.Legend);
        if axesHasLegend
            leg=ax.Legend;
            pcs=leg.PlotChildrenSpecified;
            if~isempty(pcs)
                val=plotedit({'getProxyValueFromHandle',pcs});




                curPCSproxyvalues=string(getappdata(leg,'PlotChildrenSpecifiedProxyValues'));
                val=unique([curPCSproxyvalues;val],'stable');
                setappdata(leg,'PlotChildrenSpecifiedProxyValues',val);
            end

            if~leg.AutoUpdate&&ismember(object,leg.PlotChildren)&&~ismember(object,leg.PlotChildrenSpecified)




                val=plotedit({'getProxyValueFromHandle',leg.PlotChildren});
                currDeletedPlotChildren=string(getappdata(leg,'PlotChildrenProxyValuesWhenAutoUpdateOff'));
                val=unique([currDeletedPlotChildren;val],'stable');
                setappdata(leg,'PlotChildrenProxyValuesWhenAutoUpdateOff',val);
            end

            pce=leg.PlotChildrenExcluded;
            emptyParent=false(numel(pce),1);
            for i=1:numel(pce)
                if isempty(pce(i).Parent)
                    emptyParent(i)=true;
                end
            end
            pce(emptyParent)=[];

            if~isempty(pce)
                val=plotedit({'getProxyValueFromHandle',pce});



                curPCEproxyvalues=string(getappdata(leg,'PlotChildrenExcludedProxyValues'));
                val=unique([curPCEproxyvalues;val],'stable');
                setappdata(leg,'PlotChildrenExcludedProxyValues',val);
            end
        end
    end

end

