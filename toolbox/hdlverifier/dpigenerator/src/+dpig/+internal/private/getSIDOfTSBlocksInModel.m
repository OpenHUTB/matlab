function TSBlkInfo=getSIDOfTSBlocksInModel(ModelName,TopLevelName)






    [~,~,MdlRefGraph]=find_mdlrefs(ModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    A=Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
    MdlRefAndBlocksInfo=A.analyze(MdlRefGraph,'All');

    NumberOfRefModels=height(MdlRefAndBlocksInfo);
    clean_loaded_ref_models=cell(1,NumberOfRefModels);

    TSBlkInfo=containers.Map;
    for idx=1:NumberOfRefModels
        ReferenceModel=MdlRefAndBlocksInfo.RefModel{idx};
        IsLoaded=MdlRefAndBlocksInfo.IsLoaded(idx);

        if~IsLoaded
            try
                load_system(ReferenceModel);
                clean_loaded_ref_models{idx}=onCleanup(@()bdclose(ReferenceModel));
            catch






                continue;
            end
        end



        TSBlocks=[strrep(find_system(ReferenceModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','SFBlockType','Test Sequence'),newline,' ');...
        find_system(ReferenceModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','All','FollowLinks','on','SFBlockType','Chart');...
        find_system(ReferenceModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','All','FollowLinks','on','SFBlockType','State Transition Table')];

        for BlkPath=TSBlocks'
            BlkPathStr=BlkPath{1};
            if idx==1&&~isempty(TopLevelName)







                OriginalSID=Simulink.ID.getSID([TopLevelName,'/',extractAfter(BlkPathStr,'/')]);
            else
                OriginalSID=Simulink.ID.getSID(BlkPathStr);
            end
            TSBlkInfo(BlkPathStr)=OriginalSID;
        end





        assertblks=dpig.internal.dpigprivate('getSIDOfAssertBlocksInModel',ModelName);
        for ABlkID=keys(assertblks)
            ABlkIDStr=ABlkID{1};






            fullPath=Simulink.ID.getFullName(ABlkIDStr);
            fullPath=regexprep(fullPath,'\n','\\n');




            adjustedABlkIDStr=l_getOriginalSID(ABlkIDStr);
            TSBlkInfo(fullPath)=adjustedABlkIDStr;
        end

    end






end


function str=l_getOriginalSID(TempSID)
    SubSysPath=dpigenerator_getvariable('dpigSubsystemPath');



    if isempty(SubSysPath)
        str=TempSID;
    else
        str=strrep(TempSID,strtok(TempSID,':'),strtok(SubSysPath,'/'));
    end
end
