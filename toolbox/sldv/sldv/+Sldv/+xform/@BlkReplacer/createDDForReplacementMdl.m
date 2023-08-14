function createDDForReplacementMdl(origModelH,repMdlH,testComp)


























    [mdlHierarchyHasDD,mdlBlks]=Sldv.utils.checkAndListMdlBlksIfMdlHierarchyHasDD(origModelH);

    if mdlHierarchyHasDD


        if~isempty(testComp)
            repMdlDDFilePath=sldvprivate('mdl_get_output_dir',testComp);
        else



            repMdlDDFilePath=pwd;
        end




        repMdlDDName=[get_param(repMdlH,'Name'),'_DD.sldd'];

        replacementDataDictionaryPath=[repMdlDDFilePath,filesep,repMdlDDName];
        if isfile(replacementDataDictionaryPath)








            Simulink.data.dictionary.closeAll(repMdlDDName,'-discard');
            delete(replacementDataDictionaryPath);
            repMdlDDObj=Simulink.data.dictionary.create(replacementDataDictionaryPath);
        else
            repMdlDDObj=Simulink.data.dictionary.create(replacementDataDictionaryPath);
        end
        saveChanges(repMdlDDObj);
        set_param(repMdlH,'DataDictionary',repMdlDDName);

        ddNameTop=get_param(origModelH,'DataDictionary');
        if isempty(ddNameTop)
            entryNamesInDesignDataSectionTop={};
        else
            ddTopObj=Simulink.data.dictionary.open(ddNameTop);
            designDataSectionTop=getSection(ddTopObj,'Design Data');
            entriesInDesignDataSectionTop=find(designDataSectionTop);
            entryNamesInDesignDataSectionTop={entriesInDesignDataSectionTop.Name};
        end

        attachAllDD=attachTopMdlDDOrAllDDs(mdlBlks,entryNamesInDesignDataSectionTop);

        if attachAllDD
            topMdlDA=Simulink.data.DataAccessor.createForGlobalNameSpaceClosure(origModelH);
            topMdlDA.addDataSourceToDest(repMdlH);
            repModelDDObj=Simulink.data.dictionary.open(replacementDataDictionaryPath);
        else
            repModelDDObj=Simulink.data.dictionary.open(replacementDataDictionaryPath);
            addDataSource(repModelDDObj,ddNameTop);
        end
        saveChanges(repModelDDObj);
    end
end

function attachAllDD=attachTopMdlDDOrAllDDs(mdlBlks,entryNamesInDesignDataSectionTop)
    attachAllDD=false;

    for i=1:length(mdlBlks)
        mdlBlkH=get_param(mdlBlks{i},'Handle');
        refMdlName=get_param(mdlBlkH,'ModelName');
        refMdlH=get_param(refMdlName,'Handle');

        ddNameRef=get_param(refMdlH,'DataDictionary');

        if isempty(ddNameRef)
            entryNamesInDesignDataSectionRef={};
        else
            ddRefObj=Simulink.data.dictionary.open(ddNameRef);
            designDataSectionRef=getSection(ddRefObj,'Design Data');
            entriesInDesignDataSectionRef=find(designDataSectionRef);
            entryNamesInDesignDataSectionRef={entriesInDesignDataSectionRef.Name};
        end

        entriesOnlyInRefModel={};
        if~isempty(entryNamesInDesignDataSectionRef)
            commonEntriesInTopAndRef=intersect(entryNamesInDesignDataSectionTop,...
            entryNamesInDesignDataSectionRef);

            entriesOnlyInRefModel=setdiff(entryNamesInDesignDataSectionRef,...
            commonEntriesInTopAndRef);
        end

        if~isempty(entriesOnlyInRefModel)



            attachAllDD=true;
            return;
        end
    end
end
