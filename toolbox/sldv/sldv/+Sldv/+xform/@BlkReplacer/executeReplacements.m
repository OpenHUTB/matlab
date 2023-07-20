function[status,modelH,errorMsg]=executeReplacements(obj,modelH,opts,showUI,testcomp)




    wstate=warning('backtrace');
    vnvcopystate=get_param(0,'CopyBlkRequirement');

    warning('backtrace','off');
    set_param(0,'CopyBlkRequirement','off');

    if isempty(find_system('SearchDepth',0,'Name','simulink'))
        obj.addToOpenedModelsList('simulink');
        Sldv.load_system('simulink');
    end

    obj.updateReplaceAndNotReplacedBlockTables;

    if~obj.MdlInlinerOnlyMode
        if nargin>4
            obj.TestComponent=testcomp;
        end
    end

    cleanupDirtyCheck=[];
    try

        obj.ErrorGroup=1;

        obj.checkModel(modelH);
        cleanupDirtyCheck=onCleanup(@()checkDirtyStatus(obj.MdlHierarchy,get_param(obj.MdlHierarchy,'Dirty')));

        if isempty(opts)
            opts=sldvoptions(obj.ModelH);
        end

        obj.SldvOptConfig=opts;

        obj.updateReplacementRules;


        obj.updateTableLibLinkBrokenSS;

        obj.updateTableSubsystemsInserted;

        obj.constructReplacementModel(showUI);










        Sldv.utils.switchObsMdlsToStandaloneMode(modelH);



        if obj.RepMdlGenerated


            obj.ErrorGroup=2;



            Sldv.xform.BlkReplacer.inlineSubsytemReferences(obj.MdlInfo.ModelH);

            displayRules=~obj.IsReplacementForAnalysis&&~obj.MdlInlinerOnlyMode;
            obj.genConfigurationRules(displayRules);


















            obj.configureAutoSaveState;


            obj.updateDesignMdlSettings;



            cleanupMdlCompile=onCleanup(@()terminateReplMdlCompile(obj));

            if~sldvprivate('isEliminateModRefInliningEnabled',obj.ModelH)
                obj.replaceMdlRefBlks;
            end

            if~obj.MdlInlinerOnlyMode
                obj.replaceSubSystems;
                obj.replaceBuiltinBlks;
            end
        end


        clear('cleanupMdlCompile');

        if~obj.MdlInlinerOnlyMode
            obj.genReplacedBlocksTable;
            obj.genNotReplacedBlocksTable;
            if~obj.IsReplacementForAnalysis&&obj.RepMdlGenerated&&...
                ~obj.MdlInlinerOnlyMode


                Sldv.xform.BlkReplacer.displayReplacedBlocksInfo(obj.MdlInfo.ModelH);
            end
        end



        obj.fixSortedOrderForDSM(obj.MdlInfo.ModelH);




        obj.MdlInfo.restoreCopyMdlParams();
        obj.restoreDesignMdlSettings();

        obj.fixInactiveMdlRefBlks();


        modelH=obj.updateGeneratedMdls();
    catch Mex
        obj.ErrorOccurred=true;

        clear('cleanupMdlCompile');



        hasMultiTasking=checkForMultiTasking(obj);


        obj.restoreDesignMdlSettings;

        if strcmp(Mex.identifier,'Sldv:xform:MdlInfo:compileBlkDiagram:FailedToCompile')
            if hasMultiTasking







                newMex=MException(message('Sldv:Compatibility:UnsupportedMultiTaskingToSingleTasking'));
                newMex=newMex.addCause(Mex);
                Mex=newMex;
            end
        elseif slavteng('feature','BusElemPortSupport')&&~strcmp(Mex.identifier,'Sldv:Compatibility:RootLvlBusElemPortNotSupported')




            hasUnsupportedBEP=sldvprivate('mdlHasUnsupportedOutBusElems',modelH);
            if hasUnsupportedBEP
                newMex=MException(message('Sldv:Compatibility:UnsupportedOutBusElementPortType'));
                newMex=newMex.addCause(Mex);
                Mex=newMex;
            end
        end

        obj.ErrorMex=Mex;
    end

    if~obj.ErrorOccurred
        status=true;
        errorMsg='';
    else
        modelH=[];
        status=false;
        errorMsg=obj.generateErrMsg(showUI);
    end



    delete(cleanupDirtyCheck);


    obj.cleanupSessionData;

    set_param(0,'CopyBlkRequirement',vnvcopystate);

    warning('backtrace',wstate.state);


    cellfun(@(x)x.closeOpenedModels(),obj.AllRules);
    obj.closeOpenedModels();
end

function terminateReplMdlCompile(blkReplacer)
    blkReplacer.MdlInfo.termModel();


    Sldv.utils.switchObsMdlsToStandaloneMode(blkReplacer.MdlInfo.ModelH);
end

function checkDirtyStatus(mdlHierarchy,origDirtyStatus)
    currentDirtyStatus=get_param(mdlHierarchy,'Dirty');


    assert(isequal(origDirtyStatus,currentDirtyStatus));
end

function hasMultiTasking=checkForMultiTasking(obj)




    hasMultiTasking=false;







    if~Sldv.utils.isValidContainerMap(obj.SettingsCacheMdlRefMap)
        return;
    end

    entries=obj.SettingsCacheMdlRefMap.keys;
    for idx=1:length(entries)
        settingsCache=obj.SettingsCacheMdlRefMap(entries{idx});



        if isfield(settingsCache.params,'SolverMode')&&...
            isfield(settingsCache.params,'AutoInsertRateTranBlk')&&...
            isfield(settingsCache.params,'SingleTaskRateTransMsg')
            hasMultiTasking=true;
            break;
        end
    end
end
