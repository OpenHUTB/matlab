function out=isParamValueEqual(model,param,value)



















    narginchk(3,3);
    cs=getActiveConfigSet(model);
    if isa(cs,'Simulink.ConfigSetRef')

        if cs.SourceResolved=="off"||cs.UpToDate=="off"
            cs.refresh(true);
        end

        if cs.SourceResolved=="off"
            out=false;
            return
        end
    end
    out=isequal(get_param(cs,param),value);
