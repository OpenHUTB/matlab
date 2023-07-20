function[a,b]=getHandle(model,sids)




    if~iscell(sids)
        sids={sids};
    end
    n=length(sids);
    a=zeros(n,1);
    for i=1:n
        try
            sid=sids{i};
            h=Simulink.URL.getHandle(sid);
            if isa(h,'Stateflow.Object')
                a(i)=h.ID;
            else
                type=get_param(h,'type');
                if strcmp(type,'port')
                    a(i)=get_param(h,'Line');
                else
                    a(i)=h;
                end
            end
        catch
        end
    end



    all=find_system(model,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FindAll','on');
    b=setdiff(all,a);

end

