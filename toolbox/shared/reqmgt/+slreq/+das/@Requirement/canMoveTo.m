function result=canMoveTo(this,view,offset)








    isExternalReq=this.isExternal;

    if~isempty(view)&&view.isSortDisabled()
        result=~isExternalReq;
    else
        result=false;
    end

    if result
        currentIndex=this.parent.findObjectIndex(this);
        lengthOfChildren=length(this.parent.children);
        dstIndex=currentIndex+offset;

        if dstIndex<1||dstIndex>lengthOfChildren
            result=false;
            return;
        end
        dstObj=this.parent.children(dstIndex);
        isdstExternal=dstObj.isExternal;
        if isdstExternal
            result=false;
            return;
        end
        isJustification=this.isJustification;
        isdstJustification=dstObj.isJustification;
        result=isdstJustification==isJustification;

    end
end
