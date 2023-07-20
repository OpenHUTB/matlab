
function cacheTunableParam(this,param,value)
    if~this.cache_tunableparam.isKey(param)
        this.cache_tunableparam(param)=value;
    end
end
