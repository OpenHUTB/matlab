function setParameter(this,param,value)



    hINI=this.getINI;

    if~isempty(findProp(hINI,param))
        setProp(hINI,param,value);
    else
        error(message('hdlcoder:engine:invalidparam',param));
    end
