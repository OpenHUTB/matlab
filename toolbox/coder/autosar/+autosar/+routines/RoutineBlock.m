classdef RoutineBlock<handle



    properties(SetAccess=private,GetAccess=protected)
BlockBuilder
    end

    methods(Static,Access=public)
        function updateCallback(blkH)
            routineImpl=autosar.routines.RoutineBlock.getRoutineImpl(blkH);
            routineImpl.update(blkH);
        end

        function updateMaskCallback(blkH)
            routineImpl=autosar.routines.RoutineBlock.getRoutineImpl(blkH);
            routineImpl.updateBlockMask(blkH);
        end

        function setupDataTypesCallback(blkH)
            routineImpl=autosar.routines.RoutineBlock.getRoutineImpl(blkH);
            routineImpl.setupSignalValidation(blkH);
        end

        function logErrorCallback(blkH,exception)
            routineImpl=autosar.routines.RoutineBlock.getRoutineImpl(blkH);
            routineImpl.logError(exception);
        end

        function resetErrorsCallback(blkH)
            routineImpl=autosar.routines.RoutineBlock.getRoutineImpl(blkH);
            routineImpl.logError([],true);
        end

        function routineBlocks=find(sys)

            routineBlocks=find_system(sys,...
            'RegExp','on',...
            'FollowLinks','on',...
            'MatchFilter',@Simulink.match.activeVariants,...
            'LookUnderMasks','all',...
            'RoutineImpl','.*');
        end

        function routineLib=getRoutineLib(blkH)
            targetLib=get_param(blkH,'TargetRoutineLibrary');
            if contains(targetLib,'IFX')
                routineLib='IFX';
            elseif contains(targetLib,'IFL')
                routineLib='IFL';
            else
                routineLib='';
            end
        end

        function isIFX=isConfiguredForIFX(blkH)
            isIFX=strcmp(autosar.routines.RoutineBlock.getRoutineLib(blkH),'IFX');
        end

        function isIFL=isConfiguredForIFL(blkH)
            isIFL=strcmp(autosar.routines.RoutineBlock.getRoutineLib(blkH),'IFL');
        end
    end

    methods(Access=public)
        function createBlock(self,system,position)
            blkH=self.createBaseBlock(system,position);
            self.setConstantParameters(blkH);
            self.applyDefaultSettings(blkH);

            maskObj=Simulink.Mask.create(blkH);
            set_param(blkH,'MaskSelfModifiable','on');
            self.populateMask(maskObj,blkH);
            maskObj.Initialization=[maskObj.Initialization,'autosar.routines.RoutineBlock.updateMaskCallback(gcb);'];
            self.updateBlockMask(blkH);
            self.setupSignalValidation(blkH);
            set_param(blkH,'InitFcn','autosar.routines.RoutineBlock.updateCallback(gcb);');
            set_param(blkH,'AttributesFormatString','%<TargetedRoutine>');
        end

        function update(self,blkH)
            assert(autosar.validation.CompiledModelUtils.isCompiled(bdroot(getfullname(blkH))));
            autosar.api.Utils.autosarlicensed(true);

            if autosar.blocks.internal.isUpdateDuringBuild(bdroot(getfullname(blkH)))&&ecoderinstalled
                signalValidationDiagLevel='error';
                if~isequal(get_param(blkH,'DiagMode'),'Error')
                    set_param(blkH,'DiagMode','Error');
                end
            else
                signalValidationDiagLevel='warn';
                if~isequal(get_param(blkH,'DiagMode'),'Warning')
                    set_param(blkH,'DiagMode','Warning');
                end
            end

            self.checkValidCRLRoutine(blkH);
            self.updateSignalValidation(blkH,signalValidationDiagLevel);
        end

        function updateBlockMask(self,blkH)
            self.updateTargetedRoutine(blkH);
        end

        function logError(~,exception,reset)
            persistent errors;
            if isempty(errors)||(nargin>2&&reset)
                errors={};
            end
            if isempty(exception)
                return;
            end
            for ii=1:numel(errors)
                if strcmp(exception.identifier,errors(ii).identifier)
                    return;
                end
            end
            errors=[errors,exception];
            sldiagviewer.reportError(exception);
        end
    end

    methods(Abstract)
        [routine,fixitCommand,messageID]=getRoutineFromBlockSettings(self,blkH);



        sourceBlock=getSourceBlock(self);


        type=getBlockType(self);


        description=getBlockDescription(self);


        constantParameters=getConstantParameters(self);



        validRoutines=getValidRoutines(self);



        setupSignalValidation(self,blkH);



        updateSignalValidation(self,blkH,mode);



    end

    methods(Access=protected,Abstract)
        applyDefaultSettings(self,blkH);



        populateMask(self,maskObj,blkH);

    end

    methods(Access=protected)
        function updateTargetedRoutine(self,blkH)


            routineImpl=self.getRoutineImpl(blkH);

            currentRoutine=get_param(blkH,'TargetedRoutine');
            routineName=routineImpl.getRoutineFromBlockSettings(blkH);
            if~strcmp(currentRoutine,routineName)
                set_param(blkH,'TargetedRoutine',routineName);
            end
            maskObj=Simulink.Mask.get(blkH);
            temp=maskObj.getDialogControl('TargetedRoutineText');
            temp.Prompt=routineName;
        end

        function checkValidCRLRoutine(self,blkH)



            function isERTTarget=isERTTarget(model)
                isERTTarget=strcmp(get_param(model,'IsERTTarget'),'on');
            end


            if~ecoderinstalled
                MSLDiagnostic('autosarstandard:routines:RoutineBlockNeedsECoder',getfullname(blkH)).reportAsWarning;

                routineImpl=self.getRoutineImpl(blkH);
                [routineName,fixitCommand,messageID]=routineImpl.getRoutineFromBlockSettings(blkH);
                if strcmp(routineName,'No Valid Routine')
                    if isempty(fixitCommand)
                        if~isempty(messageID)
                            MSLDiagnostic(messageID,getfullname(blkH)).reportAsWarning;
                        else
                            MSLDiagnostic('autosarstandard:routines:RoutineBlockNotValid',getfullname(blkH)).reportAsWarning;
                        end
                    else
                        MSLDiagnostic('autosarstandard:routines:RoutineBlockNotValidWithFixit',getfullname(blkH),fixitCommand,message(messageID).getString()).reportAsWarning;
                    end
                end

                return;
            end


            crlCache=autosar.routines.CrlCache.getInstance();
            model=bdroot(blkH);
            if~crlCache.isBlockFuncInCRL(model,blkH)
                codeReplacementLib=get_param(model,'CodeReplacementLibrary');
                [isDuringBuild,isAccelOrRAccel]=autosar.blocks.internal.isUpdateDuringBuild(bdroot(getfullname(blkH)));
                if isDuringBuild
                    if strcmp(codeReplacementLib,'AUTOSAR 4.0')
                        routineImpl=self.getRoutineImpl(blkH);
                        [~,fixitCommand,messageID]=routineImpl.getRoutineFromBlockSettings(blkH);
                        if isempty(fixitCommand)
                            if~isempty(messageID)
                                DAStudio.error(messageID,getfullname(blkH));
                            else
                                DAStudio.error('autosarstandard:routines:RoutineBlockNotValid',getfullname(blkH));
                            end
                        else
                            autosar.validation.AutosarUtils.reportErrorWithFixit('autosarstandard:routines:RoutineBlockNotValidWithFixit',getfullname(blkH),fixitCommand,messageID);
                        end
                    else
                        if isERTTarget(model)
                            MSLDiagnostic('autosarstandard:routines:RoutineBlocksNeedsCRL',getfullname(blkH),model).reportAsWarning;
                        else
                            autosar.validation.AutosarUtils.reportErrorWithFixit('autosarstandard:routines:RoutineBlocksNeedsERT',getfullname(blkH),model);
                        end
                    end
                else
                    if strcmp(codeReplacementLib,'AUTOSAR 4.0')
                        routineImpl=self.getRoutineImpl(blkH);
                        [~,fixitCommand,messageID]=routineImpl.getRoutineFromBlockSettings(blkH);
                        if isempty(fixitCommand)
                            if~isempty(messageID)
                                MSLDiagnostic(messageID,getfullname(blkH)).reportAsWarning;
                            else
                                MSLDiagnostic('autosarstandard:routines:RoutineBlockNotValid',getfullname(blkH)).reportAsWarning;
                            end
                        else
                            MSLDiagnostic('autosarstandard:routines:RoutineBlockNotValidWithFixit',getfullname(blkH),fixitCommand,message(messageID).getString()).reportAsWarning;
                        end
                    elseif~isAccelOrRAccel
                        if isERTTarget(model)
                            MSLDiagnostic('autosarstandard:routines:RoutineBlocksNeedsCRL',getfullname(blkH),model).reportAsWarning;
                        else
                            MSLDiagnostic('autosarstandard:routines:RoutineBlocksNeedsERT',getfullname(blkH),model).reportAsWarning;
                        end
                    else

                    end
                end
            end
        end

        function setConstantParameters(self,blkH)


            constantParameters=self.getConstantParameters();
            constantParameterKeys=constantParameters.keys;
            for idx=1:numel(constantParameterKeys)
                paramName=constantParameterKeys{idx};
                set_param(blkH,paramName,constantParameters(paramName));
            end
        end

        function fixitCommand=genSetParamFixit(~,blkH,paramName,value)
            fixitCommand=['autosar.routines.RoutineCallbacks.applyFixit(''',getfullname(blkH),''',''',paramName,''',''',value,''');'];
        end

        function applyAUTOSARFooter(~,maskObj)
            maskObj.BlockDVGIcon='BSWBlockIcon.AUTOSARFooter';
            maskObj.IconOpaque='transparent';
        end
    end

    methods(Access=private)
        function blkH=createBaseBlock(self,system,position)
            blkPath=[system,'/',self.getBlockType()];

            self.deleteBlkIfExists(system,self.getBlockType());
            blkH=add_block(self.getSourceBlock(),blkPath);

            set_param(blkH,'Position',position);
        end

        function deleteBlkIfExists(~,systemName,blkName)
            if~isempty(Simulink.findBlocks(systemName,'Name',blkName))
                blkPath=[systemName,'/',blkName];
                delete_block(blkPath);
            end
        end
    end

    methods(Static,Access=private)
        function routineImpl=getRoutineImpl(blkH)
            routineImpl=eval(get_param(blkH,'RoutineImpl'));
        end
    end
end







