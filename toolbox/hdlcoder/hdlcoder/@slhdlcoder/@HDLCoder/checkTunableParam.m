
function[bExists,pVal]=checkTunableParam(this,param)
    pVal=[];
    if~this.cache_tunableparam.isKey(param)
        bExists=false;
    else
        bExists=true;
        pVal=this.cache_tunableparam(param);
    end
end
