function indirectlyFlaggedHs=getIndirectlyLinkedHandles(modelObj,filterSettings)






    indirectlyFlaggedHs=[];

    if~isa(modelObj,'Simulink.BlockDiagram')

        modelObj=get_param(modelObj,'Object');
    end




    refBlockHandles=find_system(modelObj.handle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','type','block','StaticLinkStatus','resolved');
    for i=1:length(refBlockHandles)
        refBlock=get_param(refBlockHandles(i),'object');
        libPath=refBlock.ReferenceBlock;
        libName=strtok(libPath,'/');
        isNoted=false;
        if rmiut.isBuiltinNoRmi(libName)
            continue;
        elseif~any(strcmp(find_system('SearchDepth',0),libName))
            if rmi.settings_mgr('get','reportSettings','toolsReqReport')





                disp(getString(message('Slvnv:reqmgt:getReqs:LibraryNotLoaded',libPath,libName)));
            end
            continue;
        elseif rmi.objHasReqs(libPath,filterSettings)
            indirectlyFlaggedHs=[indirectlyFlaggedHs;refBlock.Handle];%#ok<AGROW>
            isNoted=true;
        end
        if slprivate('is_stateflow_based_block',refBlock.Handle)
            if~isNoted
                sfObj=get_param(libPath,'Object');
                sfObjs=find(sfObj,rmisf.sfisa('isaFilter'));
                for j=1:length(sfObjs)
                    if~isNoted&&rmi.objHasReqs(sfObjs(j),filterSettings)
                        indirectlyFlaggedHs=[indirectlyFlaggedHs;refBlock.Handle];%#ok<AGROW>
                        isNoted=true;
                    end
                end
            end
        else
            implicitBlocks=find(refBlock,'StaticLinkStatus','implicit');
            for j=1:length(implicitBlocks)




                libBlockPath=implicitBlocks(j).ReferenceBlock;
                myLibName=strtok(libBlockPath,'/');
                if~strcmp(myLibName,libName)





                elseif rmi.objHasReqs(libBlockPath,filterSettings)
                    indirectlyFlaggedHs=[indirectlyFlaggedHs;implicitBlocks(j).Handle];%#ok<AGROW>
                end
            end
        end
    end


    mdlBlocks=find(modelObj,'-isa','Simulink.ModelReference');
    for i=1:length(mdlBlocks)
        try
            mdlName=mdlBlocks(i).ModelName;
            mdlH=get_param(mdlName,'Handle');
            if rmisl.modelHasReqLinks(mdlH,true,true)
                indirectlyFlaggedHs=[indirectlyFlaggedHs;mdlBlocks(i).Handle];%#ok<AGROW>
            end
        catch ex %#ok<NASGU>

        end
    end
end
