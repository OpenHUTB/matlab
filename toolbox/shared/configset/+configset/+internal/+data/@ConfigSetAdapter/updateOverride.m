function updateOverride(obj)


    csref=obj.Source;
    if isa(csref,'Simulink.ConfigSetRef')
        s.action='updateOverride';


        params=csref.CurrentParameterOverride;


        lcs=csref.LocalConfigSet;
        if isempty(lcs)
            s.list={};
        else
            n=length(params);
            list=cell(n,1);
            for i=1:n
                param=params{i};
                cc=lcs.getPropOwner(param);
                list{i}={param,cc.isReadonlyProperty(param)};
            end
            s.list=list;
        end


        ed=configset.internal.data.ConfigSetEventData(s);
        obj.notify('CSEvent',ed);
    end

