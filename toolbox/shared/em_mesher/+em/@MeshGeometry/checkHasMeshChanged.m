function[tf,isParent,hasChild]=checkHasMeshChanged(obj)

    tf=false;
    isParent=true;

    if getHasMeshChanged(obj)
        tf=true;
        chkParent=getParent(obj);
        if~isempty(chkParent)
            isParent=false;
        end
    end









    hasChild=~isempty(getChild(obj));
