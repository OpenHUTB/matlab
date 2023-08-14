function result=promote(this)






    result=false;

    if~this.canPromote()
        return;
    end

    result=this.dataModelObj.promote();

end
