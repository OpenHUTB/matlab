function setUpXILMode(obj)





    if(Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE~=obj.mCompatStatus)&&obj.mIsXIL



        if~isempty(obj.mBlockH)
            blockType=get_param(obj.mBlockH,'blockType');
            if strcmpi(blockType,'ModelReference')
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
                obj.mTestComp.compatStatus=obj.mCompatStatus.char;
                obj.mErrorMsg=getString(message('Sldv:Compatibility:UnsupportedXilModelBlockSimulationMode'));
                obj.logAll(sprintf('\n\n%s\n\n',obj.mErrorMsg));
                return
            elseif~sldv.code.internal.isAtsEnabled()
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
                obj.mTestComp.compatStatus=obj.mCompatStatus.char;
                obj.mErrorMsg=getString(message('Sldv:Compatibility:UnsupportedXilSubsytemSimulationMode'));
                obj.logAll(sprintf('\n\n%s\n\n',obj.mErrorMsg));
                return
            end

        end

        if Sldv.utils.Options.isTestgenTargetForModelRefCode(obj.mTestComp.activeSettings)
            msgKey='sldvTestGenForCodeGenModelRef';
        else
            msgKey='sldvTestGenForCodeGen';
        end

        testGenTargetStr=getString(message(['Sldv:dialog:',msgKey]));
        if~obj.mSkipTranslation
            msg=message('Sldv:Setup:CheckingXilTestGenerationCompatibility',testGenTargetStr);
            obj.logAll(getString(msg));
        end



        if obj.mTestComp.analysisInfo.blockDiagramExtract
            Sldv.Translator.xilUtils('fixBDExtractedWrapperModel',...
            obj.mExtractedModelH,obj.mTestComp.simMode);
        end


        obj.mTestComp.profileStage('CodeCompatibilityCheck');
        obj.mTestComp.getMainProfileLogger().openPhase('CodeCompatibilityCheck');


        [status,obj.mErrorMsg,xilCodeAnalyzer]=sldv.code.xil.CodeAnalyzer.checkCompatibility(...
        get_param(obj.mTestComp.analysisInfo.designModelH,'Name'),...
        'ExtractedModelName',get_param(obj.mExtractedModelH,'Name'),...
        'isBDExtractedModel',obj.mTestComp.analysisInfo.blockDiagramExtract,...
        'SimulationMode',SlCov.CovMode.fromString(obj.mTestComp.simMode),...
        'FilterExistingCov',obj.mFilterExistingCov,...
        'StartCovData',obj.mTestComp.startCovData,...
        'SubsystemModelH',obj.mTestComp.analysisInfo.analyzedSubsystemH,...
        'SldvSettings',obj.mTestComp.activeSettings,...
        'LogFcn',@(msg)logAll(obj,msg));



        obj.mTestComp.profileStage('end');
        obj.mTestComp.getMainProfileLogger().closePhase('CodeCompatibilityCheck');


        status=status&&~isempty(xilCodeAnalyzer);
        if~status
            obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
            obj.mTestComp.compatStatus=obj.mCompatStatus.char;
            obj.logAll(sprintf('\n\n%s\n\n',obj.mErrorMsg));
        else
            obj.logAll(newline);
            obj.mTestComp.codeAnalyzer=xilCodeAnalyzer;





            obj.mTranslationState.XILChecksum=...
            Sldv.Compatibility.ChecksumCalculator.getXilChecksum(obj.mTestComp.analysisInfo.designModelH,...
            SlCov.CovMode.fromString(obj.mTestComp.simMode));





            if isempty(obj.mTranslationState.XILChecksum)
                tMsgID='Sldv:Setup:XILChecksumComputationFailed';
                tMsg=getString(message(tMsgID,testGenTargetStr));
                sldvshareprivate('avtcgirunsupcollect','push',...
                obj.mTestComp.analysisInfo.designModelH,'sldv_warning',tMsg,tMsgID);

            elseif obj.hasXILInfoChanged()





                obj.mSkipTranslation=false;
                str=getString(message('Sldv:Setup:ChangeDetected'));
                obj.logAll(sprintf('%s\n',str));
            end
        end
    end
end


