function updatePrototypeName(this,oldName,newName)




    mProp=this.findprop(oldName);
    if~isempty(mProp)
        dynProps=this.(oldName);
        delete(mProp);
        mprop=this.addprop(newName);
        mprop.Hidden=true;
        this.(newName)=dynProps;
    end

end