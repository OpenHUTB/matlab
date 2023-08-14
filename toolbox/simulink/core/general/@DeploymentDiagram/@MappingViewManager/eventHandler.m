function handled=eventHandler(h,eventType,obj)








    handled=false;
    me=h.Explorer;
    if isempty(me)
        return;
    end
    mcosObj=obj;
    switch eventType
    case 'TreeSelectionChanged'
        if~(isa(mcosObj,'Simulink.DistributedTarget.Mapping')||...
            isa(mcosObj,'Simulink.SoftwareTarget.BlockToTaskMapping_Explorer'))
            me.showDialogView(true);
            me.showListView(false);
        else
            me.showListView(true);
            me.setListViewStrColWidth('Name','W',10);
            me.showDialogView(false);
        end
    otherwise
    end
