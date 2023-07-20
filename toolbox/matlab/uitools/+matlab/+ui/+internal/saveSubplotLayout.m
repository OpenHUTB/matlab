function[SerializedSubplotLocations,SerializedSpanSubplotLocations,SerializedSubplotTitle]...
    =saveSubplotLayout(fig,axesAndCharts)



    import matlab.internal.editor.*;


    if isappdata(fig,'SubplotGrid')
        subplotgrid=getappdata(fig,'SubplotGrid');
        subplotgridLocations=zeros(size(subplotgrid));
        for k=1:numel(subplotgrid)
            ind=find(axesAndCharts==subplotgrid(k));
            if~isempty(ind)
                subplotgridLocations(k)=ind;
            end
        end




        SerializedSubplotLocations=subplotgridLocations;
    else
        SerializedSubplotLocations=[];
    end
    if isappdata(fig,'SubplotSpanGrid')
        subplotSpanGrid=getappdata(fig,'SubplotSpanGrid');
        subplotSpanGridLocations=zeros(size(subplotSpanGrid));
        for k=1:numel(subplotSpanGrid)
            ind=find(axesAndCharts==subplotSpanGrid(k));
            if~isempty(ind)
                subplotSpanGridLocations(k)=ind;
            end
        end
        SerializedSpanSubplotLocations=subplotSpanGridLocations;
    else
        SerializedSpanSubplotLocations=[];
    end
    if isappdata(fig,'SubplotGridTitle')
        SerializedSubplotTitle=getappdata(fig,'SubplotGridTitle');
    else
        SerializedSubplotTitle=[];
    end
end