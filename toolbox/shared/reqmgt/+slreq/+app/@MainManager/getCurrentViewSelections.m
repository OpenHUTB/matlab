function objs=getCurrentViewSelections()





    objs=[];

    this=slreq.app.MainManager.getInstance();
    view=this.getCurrentView();

    if~isempty(view)
        objs=view.getCurrentSelection();
    end
end