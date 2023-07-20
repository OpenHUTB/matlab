function update(obj,cc,name)






    if loc_needRefresh(name)
        obj.refresh;
        return;
    end

    mcs=configset.internal.getConfigSetStaticData;
    p=obj.getParamData(name,mcs);

    if isempty(p)

        params={[cc.Name,':',name]};
    else
        assert(~iscell(p),'parameter should be unique inside one component');

        children=p.FullChildren;
        params=[p.FullName;children];
    end

    if obj.isLocked
        obj.params=union(obj.params,params,'stable');

    else

        s.action='update';
        s.params=params;
        obj.notify('CSEvent',configset.internal.data.ConfigSetEventData(s));
    end




    if obj.debugMode
        loc_testValueDep(obj.Source,children);
    end

    function loc_testValueDep(cs,children)

        for i=1:length(children)
            cname=children{i};
            cdata=obj.getParamData(cname);
            if~isempty(cdata)
                dep=cdata.Dependency;
                if~isempty(dep)
                    [v_xml,uionly]=dep.checkValue(cs);
                    v_cs=cs.getProp(cname);

                    if~isequal(v_cs,v_xml)
                        if uionly
                            warning(['value dependency of "',cname,'" is not performed in category view']);
                        else
                            warning(['value dependency of "',cname,'" is not captured in data model']);
                        end
                    end

                end
            end
        end

        function out=loc_needRefresh(name)

            out=ismember(name,{
            'HardwareBoard',...
'Solver'
            });
