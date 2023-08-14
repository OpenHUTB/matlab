


function status=extractSubsystem(obj)
    obj.mExtractionFailed=false;

    if~isempty(obj.mBlockH)&&~obj.mSkipTranslation
        showModel=false;
        blockName=get_param(obj.mBlockH,'Name');
        blockName=strrep(blockName,newline,' ');
        blockType=get_param(obj.mBlockH,'blockType');

        if obj.mIsXIL&&~strcmp(get_param(obj.mBlockH,'blockType'),'ModelReference')&&...
            sldv.code.internal.isAtsEnabled()
            [status,obj.mErrorMsg]=obj.createHarnessForXIL();
        else
            if strcmpi(blockType,'ModelReference')
                msgStr='Sldv:Setup:CreatingNewModelModelReference';
                errMsgId='Sldv:Setup:ErrorDetectedInExtractionModelRef';
            else
                msgStr='Sldv:Setup:CreatingNewModelAtomicSubsystem';
                errMsgId='Sldv:Setup:ErrorDetectedInExtractionAtomicSS';
            end
            obj.logNewLines(getString(message(msgStr,blockName)));






            obj.clearDiagnosticInterceptor();


            oc=onCleanup(@()obj.setDiagnosticInterceptor());

            [status,obj.mExtractedModelH,obj.mErrorMsg]=...
            sldvextract(obj.mBlockH,showModel,obj.mShowUI,true);

            if status


                errorInfo=sldvshareprivate('checkCompatForSLTStubbedSLFunction',obj.mBlockH,obj.mExtractedModelH);
                if~isempty(errorInfo.identifier)
                    sldvshareprivate('avtcgirunsupcollect','push',obj.mBlockH,'sldv',...
                    errorInfo.message,errorInfo.identifier);
                    obj.mErrorMsg=sldvshareprivate('avtcgirunsupdialog',obj.mRootModelH,obj.mShowUI);
                    status=false;
                end
            end

            if~status
                errorMsg=getString(message(errMsgId,blockName));
                obj.reportExtractionFailure(errorMsg);
                return;
            end

            delete(oc);

            ExtractedModel=get_param(obj.mExtractedModelH,'FileName');
            obj.logNewLines(getString(message('Sldv:Setup:NewModelFile',ExtractedModel)));

            [solverChanged,msg]=...
            Sldv.SubSystemExtract.createForcessDiscreteMsg(obj.mExtractedModelH,obj.mRootModelH);
            if solverChanged
                obj.logAll(msg);
            end
        end
    else
        status=true;
    end
end


