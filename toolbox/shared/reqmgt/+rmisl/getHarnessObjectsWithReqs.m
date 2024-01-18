function[slReq,sfReq,reqInside,sfFade]=getHarnessObjectsWithReqs(harnessName)

    slReq=[];
    sfReq=[];
    reqInside=[];
    sfFade=[];

    if~rmisl.isComponentHarness(harnessName)
        error('%s is not a Component Harness diagram',get_param(harnessName,'Name'));
    end

    harnessObj=get_param(harnessName,'Object');
    itemsToCheck=find(harnessObj,...
    '-isa','Simulink.BlockDiagram',...
    '-or','-isa','Simulink.Block',...
    '-depth',1);%#ok<GTARG>
    filterSettings=rmi.settings_mgr('get','filterSettings');

    for i=1:length(itemsToCheck)

        obj=itemsToCheck(i);
        if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(obj)
            continue;
        end

        if rmi.objHasReqs(obj,filterSettings)
            slReq(end+1,1)=obj.Handle;%#ok<AGROW>
        end

        if isa(obj,'Simulink.SubSystem')
            children=find_system(obj.handle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'type','block');
            for j=1:length(children)
                child=get_param(children(j),'object');
                if child.Handle==obj.Handle
                    continue;
                elseif rmi.objHasReqs(child,filterSettings)
                    slReq(end+1,1)=child.Handle;%#ok<AGROW>
                end
            end
        end

        if slprivate('is_stateflow_based_block',obj.Handle)
            if strcmp(rmisf.sfBlockType(obj.Handle),'MATLAB Function')
                mfChartId=sfprivate('block2chart',obj.Handle);
                sfr=sfroot;
                mfObj=sfr.idToHandle(mfChartId);
                mfObjWithLinks=rmisf.getMFunctionsWithLinks(mfObj);
                if~isempty(mfObjWithLinks)
                    reqInside(end+1)=obj.Handle;%#ok<AGROW>
                end
            else
                [sfAllHs,sfFlags,~]=rmisf.getAllObjectsAndRmiFlags(obj,filterSettings);
                if~isempty(sfAllHs)
                    sfMoreReq=sfAllHs(sfFlags);
                    if~isempty(sfMoreReq)
                        sfReq=[sfReq;sfMoreReq];%#ok<AGROW>
                        reqInside(end+1)=obj.Handle;%#ok<AGROW>
                    end
                    sfMoreFade=sfAllHs(~sfFlags);
                    if~isempty(sfMoreFade)
                        sfFade=[sfFade;sfMoreFade];%#ok<AGROW>
                    end
                end
            end
        end
    end
    linkedReferencedBlocks=rmisl.getIndirectlyLinkedHandles(harnessObj,filterSettings);
    if~isempty(linkedReferencedBlocks)
        reqInside=[reqInside(:);linkedReferencedBlocks];
    end

end

