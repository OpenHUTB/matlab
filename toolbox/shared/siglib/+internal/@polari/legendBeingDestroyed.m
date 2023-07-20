function legendBeingDestroyed(p)



    lis=p.hListeners;
    if~isempty(lis)
        if~isempty(lis.LegendBeingDestroyed)
            delete(lis.LegendBeingDestroyed);
            lis.LegendBeingDestroyed=[];
        end
        if~isempty(lis.LegendStringChanged)
            delete(lis.LegendStringChanged);
            lis.LegendStringChanged=[];
        end
        if~isempty(lis.LegendMarkedClean)
            delete(lis.LegendMarkedClean);
            lis.LegendMarkedClean=[];
        end
        p.hListeners=lis;


        p.pLegend=false;




        addMeasurementAndLegendMenus(p,p.UIContextMenu_Master,false,false);
    end
    p.hLegend=[];
