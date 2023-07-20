function cleanupSessionData(obj)




    obj.TestComponent=[];

    if obj.RepMdlGenerated&&...
        obj.IsReplacementForAnalysis
        testcomp=obj.MdlInfo.TestComp;
        logStr=sprintf('done');
        if isa(testcomp.progressUI,'AvtUI.Progress')
            testcomp.progressUI.appendToLog(logStr);
        elseif~sldvshareprivate('util_is_analyzing_for_fixpt_tool')...
            &&~ModelAdvisor.isRunning
            fprintf(1,logStr);
        end
    end

    if obj.ErrorOccurred
        modelHToDestroy=[];
        if obj.ErrorGroup==2
            obj.destroyLibForMdlRefCopy;
            if slavteng('feature','SSysStubbing')
                obj.destroyLibForStubCopy;
            end
            modelHToDestroy=findModelToDestroy(obj);
        elseif obj.ErrorGroup==3
            obj.updateGeneratedMdls;
        end




        obj.closeLoadedReferencedModels;
        if~isempty(obj.MdlInfo)

            obj.MdlInfo.deleteRepDDIfExists();
        end
        obj.destroySessionData;
        destroyModel(modelHToDestroy);
    elseif obj.RepMdlGenerated&&(obj.MdlInlinerOnlyMode||obj.ReplacedAtLeastOnce||obj.MdlInfo.ForceReplaceModel)


        obj.destroySessionData;
    elseif obj.RepMdlGenerated


        assert(~obj.ReplacedAtLeastOnce,getString(message('Sldv:xform:BlkReplacer:BlkReplacer:NoReplacementPerformed')));
        obj.destroyLibForMdlRefCopy;
        if slavteng('feature','SSysStubbing')
            obj.destroyLibForStubCopy;
        end
        modelHToDestroy=findModelToDestroy(obj);
        obj.closeLoadedReferencedModels;
        if~isempty(obj.MdlInfo)

            obj.MdlInfo.deleteRepDDIfExists();
        end
        obj.destroySessionData;
        destroyModel(modelHToDestroy);
    else

        obj.closeLoadedReferencedModels;
        obj.destroySessionData;
    end
end

function modelHToDestroy=findModelToDestroy(obj)
    modelHToDestroy=[];
    if~isempty(obj.MdlInfo)&&...
        obj.MdlInfo.OrigModelH~=obj.MdlInfo.ModelH
        modelHToDestroy=obj.MdlInfo.ModelH;
    end
end

function destroyModel(modelHToDestroy)
    if~isempty(modelHToDestroy)
        modelToDestroyFileName=get_param(modelHToDestroy,'filename');
        Sldv.close_system(modelHToDestroy,0,'SkipCloseFcn',true);
        delete(modelToDestroyFileName);
    end
end
