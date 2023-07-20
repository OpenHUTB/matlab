function[slHs,sfHs]=getHandlesWithRequirements_hisl_0070(system)








    systemH=get_param(bdroot(system),'Handle');
    systemObj=get_param(system,'Object');


    slObjs=find(systemObj,'-isa','Simulink.BlockDiagram','-or','-isa','Simulink.Block');


    if rmidata.isExternal(systemH)
        anObjs=find(systemObj,'-isa','Simulink.Annotation');
        if~isempty(anObjs)
            slObjs=[slObjs(:);anObjs(:)];
        end
    end


    slHs=get(slObjs,'Handle');
    slHs=slHs(:);


    if iscell(slHs)
        slHs=cell2mat(slHs);
    end


    slHs=slHs(arrayfun(@(x)Advisor.Utils.Utils_hisl_0070.HandleHasReqLinks(get_param(x,'Object')),slHs));


    if rmisf.isStateflowLoaded()
        [sfHs,sfFlags]=rmisf.getAllObjectsAndRmiFlags(systemObj,rmi.settings_mgr('get','filterSettings'));
        sfHs=sfHs(sfFlags);

        sfLinkCharts=slHs(arrayfun(@(x)slprivate('is_stateflow_based_block',x),slHs));
        for ii=1:length(sfLinkCharts)
            libPath=get_param(sfLinkCharts(ii),'ReferenceBlock');
            if~isempty(libPath)
                sfObjs=find(get_param(libPath,'Object'),rmisf.sfisa('isaFilter'));
                sfIds=get(sfObjs(arrayfun(@(x)rmi.objHasReqs(x,[]),sfObjs)),'Id');
                if iscell(sfIds)
                    sfIds=cell2mat(sfIds);
                end
                sfHs=[sfHs;sfIds];
            end
        end
    else
        sfHs=[];
    end

end