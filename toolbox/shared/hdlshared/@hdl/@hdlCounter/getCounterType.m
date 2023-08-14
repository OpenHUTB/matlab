function newType=getCounterType(this,type)














    newType=type;

    if type.signed==0
        if this.Stepvalue<0||~isempty(this.cnt_dir)
            newbp=type.bp;
            newsigned=1;
            [vtyep,sltype]=hdlgettypesfromsizes(type.size,newbp,newsigned);%#ok
            newType=hdlgetallfromsltype(sltype);
        end
    end
