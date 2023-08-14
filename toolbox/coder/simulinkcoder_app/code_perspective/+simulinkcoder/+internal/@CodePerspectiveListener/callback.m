function callback(obj,varargin)




    cps=obj.cps;
    if cps.isvalid&&cps.studio.isvalid
        cps.reset();
    end

