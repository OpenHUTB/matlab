function result=canPromote(this,view)

    if(nargin<2||isempty(view))||(~isempty(view)&&view.isSortDisabled())
        result=~this.dataModelObj.external&&~isempty(this.dataModelObj.parent);
    else
        result=false;
    end
    if result


        if this.isJustification&&...
            ~isa(this.parent,'slreq.das.RequirementSet')&&...
            isa(this.parent.parent,'slreq.das.RequirementSet')

            result=false;
        end
    end
end
