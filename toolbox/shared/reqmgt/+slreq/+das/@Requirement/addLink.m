function link=addLink(this,source)






    if isa(source,'slreq.das.Requirement')
        link=this.dataModelObj.addLink(source.dataModelObj);
    else
        link=this.dataModelObj.addLink(source);
    end
end
