function cacheData(obj,analyze)




    if isempty(obj.mBDMgr)||(~obj.mIsCacheSuccess)



        if~isempty(obj.configInfoCell)
            for cIdx=1:length(obj.configInfoCell{1}{2})

                Simulink.variant.utils.assignVariableInWorkspace(...
                obj.configInfoCell{1}{2}(cIdx));
            end
        else
            if slfeature('VMgrV2UI')>0
                [success,errors]=slvariants.internal.manager.core.activateModel(obj.ModelName,obj.Configurations{1});
                if~success
                    err=MException(message('Simulink:Variants:InvalidConfigForModel',obj.Configurations{1},obj.ModelName));
                    err=Simulink.variant.utils.addActivationCausesToDiagnostic(err,errors);
                    throw(err);
                end
            else
                [success,errors]=...
                Simulink.variant.manager.configutils.validateModelWithLog(...
                obj.ModelName,obj.Configurations{1});
                if~success
                    errid='Simulink:Variants:InvalidConfigForModel';
                    errmsg=message(errid,obj.Configurations{1},obj.ModelName);
                    err=MException(errmsg);
                    err=Simulink.variant.utils.addValidationCausesToDiagnostic(err,errors);
                    throw(err);
                end
            end
        end

        if~isempty(obj.mBDMgr)
            obj.mBDMgr.delete();
        end

        opts.RecurseIntoModelReferences=true;
        refMdls=Simulink.variant.utils.i_find_mdlrefs(obj.ModelName,opts);



        dirtyFlagArray=repmat(false,1,numel(refMdls));%#ok<REPMAT>
        isSimulationPausedOrRunningFlag=repmat(false,1,numel(refMdls));%#ok<REPMAT>
        isModelInCompiledStateFlag=repmat(false,1,numel(refMdls));%#ok<REPMAT>
        for i=1:numel(refMdls)
            refModelName=refMdls{i};
            dirtyFlagArray(i)=strcmp(get_param(refModelName,'Dirty'),'on');
            isSimulationPausedOrRunningFlag(i)=Simulink.variant.utils.getIsSimulationPausedOrRunning(refModelName);
            isModelInCompiledStateFlag(i)=Simulink.variant.utils.getIsModelInCompiledState(refModelName);
        end

        if any(dirtyFlagArray)


            dirtyModels=refMdls(dirtyFlagArray);
            errid='Simulink:Variants:InvalidModelArgDirty';
            if numel(dirtyModels)==1
                errmsg=message(errid,dirtyModels{1});
                err=MException(errmsg);
            else
                err=MException(message('SL_SERVICES:utils:MultipleErrorsMessagePreamble'));
                for iter=1:numel(dirtyModels)
                    tempErr=MException(message(errid,dirtyModels{iter}));
                    err=err.addCause(tempErr);
                end
            end
            throwAsCaller(err);
        end

        if any(isSimulationPausedOrRunningFlag)



            SimulationPausedOrRunningModels=refMdls(isSimulationPausedOrRunningFlag);
            errid='Simulink:VariantManager:AnalyzingWhileRunningSimulationNotSupported';
            if numel(SimulationPausedOrRunningModels)==1
                errmsg=message(errid,SimulationPausedOrRunningModels{1});
                err=MException(errmsg);
            else
                err=MException(message('SL_SERVICES:utils:MultipleErrorsMessagePreamble'));
                for iter=1:numel(SimulationPausedOrRunningModels)
                    tempErr=MException(message(errid,SimulationPausedOrRunningModels{iter}));
                    err=err.addCause(tempErr);
                end
            end
            throwAsCaller(err);
        end

        if any(isModelInCompiledStateFlag)


            compiledModels=refMdls(isModelInCompiledStateFlag);
            errid='Simulink:VariantManager:AnalyzingWhileCompiledNotSupported';
            if numel(compiledModels)==1
                errmsg=message(errid,compiledModels{1});
                err=MException(errmsg);
            else
                err=MException(message('SL_SERVICES:utils:MultipleErrorsMessagePreamble'));
                for iter=1:numel(compiledModels)
                    tempErr=MException(message(errid,compiledModels{iter}));
                    err=err.addCause(tempErr);
                end
            end
            throwAsCaller(err);
        end



        mdlrefRebuildChanger=Simulink.variant.utils...
        .ModelReferenceTargetReplacer(obj.ModelName);
        mdlrefRebuildChanger.changeRebuildOptions();

        obj.mBDMgr=vmgrcfgplugin.VariantConfigurationManager(obj.ModelName,...
        obj.Configurations{1},obj.configurationI,obj.configInfoCell);



        obj.configurationI.resetSimVarExprMap();

        for cfgid=1:numel(obj.Configurations)
            try
                obj.mBDMgr.determineActiveBlocks(obj.Configurations{cfgid});
            catch ME


                obj.mBDMgr.delete();
                throwAsCaller(ME);
            end
        end




        errid='Simulink:VariantManager:InconsistentSlexprDefinitions';
        if slfeature('VMGRV2UI')>0
            try
                slvariants.internal.configobj.throwInconsistentSlexprDefinitions(...
                obj.ModelName,...
                obj.Configurations,...
                errid);
            catch ex
                obj.mBDMgr.delete();
                throwAsCaller(ex);
            end
        else
            varNameSimParamExpressionHierarchyMap=obj.configurationI.getSimExprMap();
            dataDictionaries=varNameSimParamExpressionHierarchyMap.keys;
            for i=1:numel(dataDictionaries)
                err=Simulink.variant.utils.getInconsistentSlexprError(...
                varNameSimParamExpressionHierarchyMap(dataDictionaries{i}),...
                numel(obj.Configurations),...
                errid);
                if~isempty(err)
                    obj.mBDMgr.delete();
                    throwAsCaller(err);
                end
            end
        end




        obj.mIsCacheSuccess=true;
    end

    if(analyze&&isempty(obj.mBlkAnalysisInfo))



        obj.analyzeBlocks();
    end
end


