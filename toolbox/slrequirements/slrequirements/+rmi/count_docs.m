function[docs,sys,counters]=count_docs(modelH,option)




    filterSettings=rmi.settings_mgr('get','filterSettings');
    [slAllHs,sfAllHs,slFlags,sfFlags,indirectObjHs]=rmisl.getAllObjectsAndRmiFlags(modelH,filterSettings);
    slHs=slAllHs(slFlags);
    sfHs=sfAllHs(sfFlags);
    switch option
    case 'all'
        objects=[slHs(:);sfHs(:)];
    case 'simulink'
        objects=slHs(:);
    case 'stateflow'
        objects=sfHs(:);
    case 'withLibs'
        objects=[slHs(:);sfHs(:);libObjsWithReqs(slAllHs(2:end),filterSettings)];
    otherwise
    end



    crossDomainItems={};
    if~isempty(indirectObjHs)&&rmisf.isStateflowLoaded()
        sfRoot=Stateflow.Root;
        for i=1:length(indirectObjHs)
            if floor(indirectObjHs(i))<indirectObjHs(i)
                chartObj=sf('Private','block2chart',indirectObjHs(i));
            else
                chartObj=indirectObjHs(i);
            end
            if~isempty(chartObj)&&chartObj~=0
                key=Simulink.ID.getSID(sfRoot.idToHandle(chartObj));
                if rmiml.hasLinks(key)
                    crossDomainItems{end+1}=key;
                end
            end
        end
    end

    docs={};
    sys={};
    counters=[];
    for obj=objects'


        if floor(obj)==obj&&sf('get',obj,'.isa')==sf('get','default','chart.isa')
            if rmidata.isExternal(bdroot(sf('Private','chart2block',obj)))
                continue;
            end
        end
        reqs=rmi.getReqs(obj);
        if filterSettings.enabled
            reqs=rmi.filterTags(reqs,filterSettings.tagsRequire,filterSettings.tagsExclude);
        end
        for req=reqs'
            if~req.linked
                continue;
            end
            [docs,sys,counters]=addCountedPair(docs,sys,counters,req.doc,req.reqsys,1);
        end
    end

    if strcmp(option,'all')&&~isempty(crossDomainItems)
        for i=1:length(crossDomainItems)
            [moreDocs,moreSys,moreCounts]=rmiml.countDocs(crossDomainItems{i});
            for j=1:length(moreDocs)
                [docs,sys,counters]=addCountedPair(docs,sys,counters,moreDocs{j},moreSys{j},moreCounts(j));
            end
        end
    end

end

function libObjs=libObjsWithReqs(slHs,filterSettings)

    libObjs=[];

    for obj=slHs'
        if any(strcmp(get_param(obj,'Type'),{'block_diagram','annotation'}))
            continue;
        end
        linkStatus=get_param(obj,'StaticLinkStatus');
        switch linkStatus
        case 'implicit'
            if rmi.objHasReqs(obj,filterSettings)
                libObjs=[libObjs;obj];
            end
        case 'resolved'
            libObj=get_param(obj,'ReferenceBlock');
            try
                libObjH=get_param(libObj,'Handle');
            catch ME %#ok<NASGU>

                load_system(strtok(libObj,'/'));
                libObjH=get_param(libObj,'Handle');
            end
            if rmi.objHasReqs(libObjH,filterSettings);
                libObjs=[libObjs;libObjH];
            end


            if slprivate('is_stateflow_based_block',libObj)
                libObjs=[libObjs;sfLibObjsWithReqs(libObj,filterSettings)];
            end

        otherwise
        end
    end
end

function sfWithReqs=sfLibObjsWithReqs(chartObj,filterSettings)
    sfWithReqs=[];
    chartId=sf('Private','block2chart',chartObj);
    if sf('Private','is_eml_chart',chartId)||sf('Private','is_truth_table_chart',chartId)
        return;
    end
    sfWithReqs=sfDescendentsWithReqs(chartId,filterSettings);
end

function sfWithReqs=sfDescendentsWithReqs(parentId,filterSettings)
    sfWithReqs=[];
    trans=sf('TransitionsOf',parentId);
    for tran=trans(:)'
        if rmi.objHasReqs(tran,filterSettings)
            sfWithReqs=[sfWithReqs;tran];
        end
    end
    substates=sf('AllSubstatesOf',parentId);
    for state=substates(:)'
        if rmi.objHasReqs(state,filterSettings)
            sfWithReqs=[sfWithReqs;state];
        end
        sfWithReqs=[sfWithReqs;sfDescendentsWithReqs(state,filterSettings)];
    end
end

function[keys,types,counts]=addCountedPair(keys,types,counts,key,type,count)

    if isempty(key)
        return;
    end

    if isempty(keys)
        keys{1}=key;
        types{1}=type;%#ok<*AGROW>
        counts(1)=count;
    else
        matches=strcmp(key,keys);
        if any(matches)
            which=find(matches==true);
            counts(which)=counts(which)+count;
        else
            keys{end+1}=key;
            types{end+1}=type;
            counts(end+1)=count;
        end
    end
end

