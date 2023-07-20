function out=getStateflowObjectParentChart(h)







    out=[];
    if~isa(h,'Stateflow.Object')
        return;
    end
    if isa(h.up,'Stateflow.Object')
        h=h.up;
        while isprop(h,'IsSubchart')&&~h.IsSubchart
            h=h.up;
        end
    end
    out=h;
