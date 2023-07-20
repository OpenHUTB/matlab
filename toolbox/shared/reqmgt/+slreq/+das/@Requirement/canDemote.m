function result=canDemote(this,view)





    thisIndex=this.findChildIndex();

    if(nargin<2||isempty(view))||(~isempty(view)&&view.isSortDisabled())
        result=~(this.dataModelObj.external||thisIndex==1);
    else
        result=false;
    end

    if result
        if this.isJustification&&isa(this.parent,'slreq.das.RequirementSet')
            result=false;
        elseif thisIndex>1
            if this.parent.children(thisIndex-1).dataModelObj.external


                result=false;
            end
        end
    end
end
