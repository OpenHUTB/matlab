function[slHs,sfHs,slFlags,sfFlags,indirectlyFlaggedHs]=getAllObjectsAndRmiFlags(modelH,filterSettings)







    modelObj=get_param(modelH,'Object');
    slObjs=find(modelObj,'-isa','Simulink.BlockDiagram',...
    '-or','-isa','Simulink.Block');%#ok<GTARG>


    if rmidata.isExternal(modelH)
        anObjs=find(modelObj,'-isa','Simulink.Annotation');
        if~isempty(anObjs)
            slObjs=[slObjs(:);anObjs(:)];
        end
    end


    slHs=get(slObjs,'Handle');
    slHs=slHs(:);


    if iscell(slHs)
        slHs=cell2mat(slHs);
    end



    if nargin<2
        filterSettings=rmi.settings_mgr('get','filterSettings');
    end
    slFlags=false(length(slHs),1);
    for i=1:length(slHs)
        if rmi.objHasReqs(slHs(i),filterSettings)
            slFlags(i)=true;
        end
    end


    if rmisf.isStateflowLoaded()
        [sfHs,sfFlags,sfObjs]=rmisf.getAllObjectsAndRmiFlags(modelObj,filterSettings,slHs(slFlags));
    else
        sfHs=[];sfFlags=[];sfObjs=[];
    end

    if nargout==5


        if isempty(sfObjs)||isempty(sfObjs(sfFlags))


            indirectlyFlaggedHs=[];
        else
            uniqueChartIdsForSfObjsWithReqs=obj_chart(sfHs(sfFlags));
            sfChartBlocks=sf('Private','chart2block',uniqueChartIdsForSfObjsWithReqs);
            indirectlyFlaggedHs=sfChartBlocks(:);
        end

        if rmidata.isExternal(modelH)&&~isempty(sfObjs)&&~isempty(which('rmiml.enable'))



            [mfunctionHandlesWithLinks,sfMFncIdx]=rmisf.getMFunctionsWithLinks(sfObjs);
            if~isempty(mfunctionHandlesWithLinks)
                indirectlyFlaggedHs=unique([indirectlyFlaggedHs;mfunctionHandlesWithLinks]);
            end
            if any(sfMFncIdx)

                sfFlags(sfMFncIdx)=true;
            end
        end




        linkedReferencedBlocks=rmisl.getIndirectlyLinkedHandles(modelObj,filterSettings);
        if~isempty(linkedReferencedBlocks)
            indirectlyFlaggedHs=[indirectlyFlaggedHs;linkedReferencedBlocks];
        end

    end
end