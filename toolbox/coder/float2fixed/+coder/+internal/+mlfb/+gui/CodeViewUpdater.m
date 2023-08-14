classdef(Sealed)CodeViewUpdater<handle







    methods(Static,Hidden)
        function runsDeleted(varargin)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doRunDeleted',varargin{:});
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnFloatToFixedManager(...
            'doInvalidateOnRunsDeleted',varargin{:});
        end

        function runRenamed(oldName,newName)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doRunRenamed',oldName,newName);
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnFloatToFixedManager(...
            'doRemapOnRunRename',oldName,newName);
        end

        function runChanged(run)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doRunChanged',run);
        end

        function outputVariantChanged(origBlockSid,outputVariantSid)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doOutputVariantChanged',origBlockSid,outputVariantSid);
        end

        function typesProposed(blockSid)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doTypesProposed',blockSid,true);
        end

        function typesApplied(success)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doTypesApplied',success);
        end

        function sudChanged(sudObject)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doSudChanged',sudObject);
        end

        function proposedTypeAnnotated(varResult)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doProposedTypeAnnotated',varResult);
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnFloatToFixedManager(...
            'doInvalidateOnResultChange',varResult);
        end

        function markMlfbResultsProcessed(runName,mlfb)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doMlfbResultsProcessed',runName,mlfb);
        end

        function markVariantCreationStart(affectedSid)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doMarkVariantCreationStart',affectedSid);
        end

        function markVariantCreationEnd(affectedSid,varSubSys,newCreation)
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doMarkVariantCreationEnd',affectedSid,varSubSys,newCreation);
        end

        function markSimCompleted()
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doMarkSimCompleted');
        end

        function fixedPointToolClosing()
            coder.internal.mlfb.gui.CodeViewUpdater.invokeOnCodeView(...
            'doFixedPointToolClosing');
        end
    end


    methods(Static,Hidden)
        function updateGlobalEnabledState(enabled)
            import coder.internal.mlfb.gui.CodeViewUpdater;
            CodeViewUpdater.manageEnabled('set',enabled);
            CodeViewUpdater.invokeOnCodeView('doNotifyCodeViewOfActionState',enabled);
        end

        function enabled=isGloballyEnabled()
            enabled=coder.internal.mlfb.gui.CodeViewUpdater.manageEnabled('get');
        end
    end

    methods(Static,Access=private)
        function varargout=invokeOnCodeView(methodName,varargin)
            if~coder.internal.mlfb.gui.MlfbUtils.isCodeViewFeaturedOn()||~usejava('swing')
                return;
            end

            try
                assert(ischar(methodName));
                qualifiedName=['coder.internal.mlfb.gui.CodeViewUpdater.',methodName];

                codeView=coder.internal.mlfb.gui.CodeViewManager.getActiveCodeView();

                if~isempty(codeView)
                    assert(isa(codeView,'coder.internal.mlfb.gui.CodeViewManager'));

                    if nargout>0
                        [varargout{1:nargout}]=feval(qualifiedName,codeView,varargin{:});
                    else
                        feval(qualifiedName,codeView,varargin{:});
                    end
                end
            catch me
                coder.internal.gui.asyncDebugPrint(me);
            end
        end

        function varargout=invokeOnFloatToFixedManager(methodName,varargin)
            if~coder.internal.mlfb.gui.MlfbUtils.isCodeViewFeaturedOn()||~usejava('swing')
                return;
            end

            try
                assert(ischar(methodName));
                qualifiedName=['coder.internal.mlfb.gui.CodeViewUpdater.',methodName];
                if nargout>0
                    [varargout{1:nargout}]=feval(qualifiedName,codeView,varargin{:});
                else
                    feval(qualifiedName,varargin{:});
                end
            catch me
                coder.internal.gui.asyncDebugPrint(me);
            end
        end

        function doRunDeleted(codeView,runNameCell)
            assert(iscell(runNameCell));
            runNames=runNameCell{1};

            if isempty(runNames)

                runNames=java.util.Collections.emptyList();
            else
                runNames=java.util.Arrays.asList(runNames);
            end

            modelName=coder.internal.mlfb.gui.CodeViewUpdater.getActiveModelName();
            codeView.notifyCodeView('runsDeleted',modelName,runNames);
        end

        function doRunCreated(codeView,source,run)
            assert(isa(run,'fxptds.FPTRun'));
            codeView.notifyCodeView('runCreated',source,run.getRunName());
            coder.internal.mlfb.gui.CodeViewUpdater.doLastUpdatedChanged(codeView,source,run.getRunName());
        end

        function doMlfbResultsProcessed(~,runName,mlfb)
            coder.internal.mlfb.gui.CodeViewUpdater.manageSimBlocks('add',runName,coder.internal.mlfb.idForBlock(mlfb));
        end

        function doRunRenamed(codeView,oldName,newName)
            assert(ischar(oldName)&&ischar(newName));
            codeView.notifyCodeView('runRenamed',coder.internal.mlfb.gui.CodeViewUpdater.getActiveModelName(),oldName,newName);
        end

        function doLastUpdatedChanged(codeView,source,runName)
            assert(ischar(runName));
            codeView.notifyCodeView('runLastUpdatedChanged',source,runName);
        end

        function doOutputVariantChanged(codeView,origBlockSid,outputVariantSid)
            outputCode='';
            if~isempty(outputVariantSid)
                outputCode=coder.internal.gui.GuiUtils.getFunctionBlockCode(origBlockSid);
            end
            codeView.notifyCodeView('outputVariantChanged',outputVariantSid,outputCode);
        end

        function doTypesProposed(codeView,blockSid,success)
            if success
                blockSid=Simulink.ID.getSID(blockSid);
                runName=coder.internal.mlfb.gui.MlfbUtils.getFptActionableRun(blockSid);
                assert(~isempty(runName)&&ischar(runName));
                run=coder.internal.mlfb.gui.MlfbUtils.getFptRunByName(blockSid,runName);
                codeView.notifyCodeView('runTypeProposalsChanged',bdroot(blockSid),runName,run.hasDataTypeProposals());
            end

            codeView.notifyCodeView('typesProposed',success);
        end

        function doTypesApplied(codeView,success)
            codeView.markTypesApplied(success);
        end

        function doSudChanged(codeView,~)
            codeView.notifyCodeView('sudChanged');
        end

        function doProposedTypeAnnotated(codeView,varResult)
            if~isa(varResult,'fxptds.MATLABVariableResult')
                return;
            end

            [functionId,varName,varInstance]=coder.internal.MLFcnBlock.Float2FixedManager.getVarMapping(varResult);

            if~isempty(functionId)&&~isempty(varName)
                if isempty(varInstance)||varResult.getUniqueIdentifier().NumberOfInstances==1
                    varSpec=-1;
                else
                    varSpec=varInstance;
                end

                codeView.notifyCodeView('fptProposedTypeAnnotated',functionId,varName,varSpec,varResult.getProposedDT(),true);
            end
        end

        function doMarkVariantCreationStart(codeView,affectedSid)
            codeView.markVariantCreationStart(Simulink.ID.getSID(affectedSid));
        end

        function doMarkVariantCreationEnd(codeView,mlfbSid,varSubSys,newCreation)
            codeView.markVariantCreationEnd(Simulink.ID.getSID(mlfbSid),Simulink.ID.getSID(varSubSys),newCreation);
        end

        function doFixedPointToolClosing(codeView)
            codeView.close();
        end

        function doNotifyCodeViewOfActionState(codeView,enabled)
            codeView.fptGlobalActionStateChanged(enabled);
        end

        function doMarkSimCompleted(codeView)
            [runName,mlfbs]=coder.internal.mlfb.gui.CodeViewUpdater.manageSimBlocks('getAndClear');

            if~isempty(runName)
                changeSource=coder.internal.mlfb.gui.CodeViewUpdater.getActiveModelName();
                mlfbs=coder.internal.mlfb.idForBlock(mlfbs);
                mlfbs=coder.internal.mlfb.gui.MlfbUtils.idsToJava('set',mlfbs{:});
                codeView.notifyCodeView('runUpdated',changeSource,runName,mlfbs);
                coder.internal.mlfb.gui.CodeViewUpdater.doLastUpdatedChanged(codeView,changeSource,runName);
            end
        end

        function varargout=manageEnabled(mode,value)
            assert(any(ismember({'set','get'},'set')));
            assert(exist('value','var')==strcmp(mode,'set'));

            mlock;
            persistent enabledState;

            if strcmp(mode,'set')
                assert(islogical(value));
                enabledState=value;
                varargout={};
            else
                if isempty(enabledState)
                    enabledState=true;
                end
                varargout={enabledState};
            end
        end

        function varargout=manageSimBlocks(cmd,runName,mlfb)
            assert(any(ismember({'add','getAndClear'},cmd)));
            persistent changedRun;
            persistent changedMlfbs;

            if strcmp(cmd,'add')
                narginchk(3,3);
                mlock;

                mlfb=coder.internal.mlfb.idForBlock(mlfb);
                if isempty(changedMlfbs)
                    changedMlfbs={mlfb};
                else
                    changedMlfbs{end+1}=mlfb;
                end
                changedRun=runName;

                varargout={};
            elseif~isempty(changedMlfbs)
                munlock;
                assert(~isempty(changedRun));
                narginchk(1,1);

                varargout={changedRun,changedMlfbs};
                changedRun=[];
                changedMlfbs={};
            else
                varargout={[],{}};
            end
        end

        function modelName=getActiveModelName()
            sud=coder.internal.mlfb.FptFacade.invoke('getSud');
            assert(~isempty(sud),'SUD should be set');
            modelName=bdroot(sud.getFullName());
        end
    end


    methods(Static,Access=private)
        function doInvalidateOnResultChange(result)
            coder.internal.MLFcnBlock.Float2FixedManager.cacheInvalidateOnly(...
            result.getUniqueIdentifier().MATLABFunctionIdentifier.SID,...
            result.getRunName());
        end

        function doInvalidateOnRunsDeleted(varargin)
            coder.internal.MLFcnBlock.Float2FixedManager.cacheInvalidateForRun(varargin{:});
        end

        function doRemapOnRunRename(oldName,newName)
            coder.internal.MLFcnBlock.Float2FixedManager.cacheRunRemapped(oldName,newName);
        end
    end

    methods(Access=private)
        function this=CodeViewUpdater()
        end
    end
end