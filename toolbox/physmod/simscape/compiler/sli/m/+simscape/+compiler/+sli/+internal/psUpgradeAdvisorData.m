function data=psUpgradeAdvisorData(model)





    [sf,ins,outs]=simscape.compiler.sli.componentModel(model,false);

    data=struct('legacy',{{}},'failed',{[]},'upgradable',{{}});

    if isempty(sf)

        return;
    elseif~iscell(sf)
        sf={sf};
        ins={ins};
        outs={outs};
    end

    assert(numel(sf)==numel(ins));
    assert(numel(sf)==numel(outs));

    upgradeStruct=simscape.compiler.mli.internal.PSLegacyList;

    for i=1:numel(sf)
        tmp=simscape.internal.PSUpgradeAdvisor(sf{i},ins{i},outs{i},upgradeStruct);
        data.legacy=[data.legacy;tmp.legacy];
        data.failed=[data.failed;tmp.failed];
    end

    toFilter=[];
    for i=1:numel(data.failed)

        data.failed(i).objects=intersect(data.failed(i).objects,data.legacy);


        if isempty(data.failed(i).objects)
            toFilter(end+1)=i;
        end
    end


    data.failed(unique(toFilter))=[];


    data.upgradable=setdiff(data.legacy,vertcat(data.failed.objects));


    parents=unique(get_param(data.legacy,'Parent'));
    parentTypes=get_param(parents,'Type');
    subsysParents=strcmp(parentTypes,'block');
    linkedLibs=lLinkedLibSubsys(parents(subsysParents));

    linkedLibId='physmod:simscape:compiler:mli:diagnostics:LinkedLibrarySubsystem';


    for i=1:numel(data.failed)
        failedLinked={};
        for j=1:numel(linkedLibs)
            if any(startsWith(data.failed(i).objects,[linkedLibs{j},'/']))
                failedLinked{end+1}=linkedLibs{j};
            end
        end
        if~isempty(failedLinked)
            linkedSubsys=strjoin(strcat('''',failedLinked,''''),', ');
            exe=pm_exception(linkedLibId,linkedSubsys);
            data.failed(i).exe=[data.failed(i).exe;exe];
        end
    end



    for i=1:numel(linkedLibs)
        idx=startsWith(data.upgradable,[linkedLibs{i},'/']);
        if any(idx)
            exe=pm_exception(linkedLibId,['''',linkedLibs{i},'''']);
            data.failed(end+1)=struct('objects',{data.upgradable(idx)},...
            'reason',{'linkedlib'},...
            'exe',{exe});
            data.upgradable(idx)=[];
        end
    end

end

function linked=lLinkedLibSubsys(subsys)



    if isempty(subsys)
        linked={};
        return;
    end
    linkStatus=get_param(subsys,'LinkStatus');
    resolved=subsys(strcmp(linkStatus,'resolved'));
    implicit=subsys(strcmp(linkStatus,'implicit'));
    parents=unique(get_param(implicit,'Parent'));
    linked=unique(vertcat(resolved,lLinkedLibSubsys(parents)));
end