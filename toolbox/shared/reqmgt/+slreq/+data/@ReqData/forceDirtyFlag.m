function forceDirtyFlag(this,dataContainer,value)









    if isa(dataContainer,'slreq.data.LinkSet')&&~value

        dataContainer.setDirty(false);
    else
        mfObject=this.getModelObj(dataContainer);
        mfObject.dirty=value;
    end
end
