function obj=getCurrentObject()






    this=slreq.app.MainManager.getInstance();
    obj=this.currentObject;

    if numel(obj)>1&&isa(obj,'slreq.das.Requirement')

        obj=slreq.das.Requirement.sortByIndex(obj);
    end
end
