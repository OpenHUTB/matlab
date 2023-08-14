function changeSelectedEdge(this,edge)




    this.SelectedEdge=edge;
    edgeSelected=evolutions.internal.ui.GenericEventData(edge);
    notify(this,'EdgeSelectionChanged',edgeSelected);
end
