function tf=isJustification(this)





    if isempty(this.dataModelObj)
        tf=false;
    else
        tf=this.dataModelObj.isJustification;
    end
end
