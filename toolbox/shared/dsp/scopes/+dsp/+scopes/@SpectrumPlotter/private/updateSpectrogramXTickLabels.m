function updateSpectrogramXTickLabels(this)




    hAxes=this.Axes;
    if this.ShowXAxisLabels&&~isempty(hAxes)&&strcmp(hAxes(2).Visible,'on')
        if strcmp(this.pXTickLabelMode,'auto')||isempty(this.pXTickLabel)
            if this.FrequencyMultiplier==1
                set(hAxes,'XTickLabelMode','auto');
                return
            end

            xTicks=get(hAxes(1,2),'XTick')*this.FrequencyMultiplier;
            xTickLabels=num2str(xTicks',6);
        else
            xTickLabels=this.pXTickLabel;
        end


        if(length(xTicks)>1)&&(length(cellstr(xTickLabels))~=length(unique(cellstr(xTickLabels))))
            setHzPerDivReadout(this);
        else
            if~isempty(this.XAxisHzPerDivReadout)
                delete(this.XAxisHzPerDivReadout);
                this.XAxisHzPerDivReadout=[];
            end
            set(hAxes(1,2),'XTickLabel',xTickLabels);
        end
    end
end