function u=getUniqueEmlParamNum(this,clear)%#ok<INUSL>



    if(nargin<2)
        clear=false;
    end

    persistent p;
    if isempty(p)||clear
        p=0;
    end

    u=p;
    p=p+1;

