function result=demote(this)






    result=false;

    if~this.canDemote()
        return;
    end


    thisIndex=this.findChildIndex();
    if thisIndex>1
        result=this.dataModelObj.demote();

    end
end
