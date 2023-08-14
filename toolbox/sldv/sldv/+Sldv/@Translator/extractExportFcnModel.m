function status=extractExportFcnModel(obj)





    status=true;
    if~isempty(obj.mBlockH)
        obj.mTestComp.analysisInfo.blockDiagramExtract=false;
        return;
    end

    if obj.mSkipTranslation
        return;
    end

    if strcmp(get_param(obj.mRootModelH,'IsExportFunctionModel'),'on')
        showModel=false;
        mdlName=get_param(obj.mRootModelH,'name');
        obj.logNewLines(getString(message('Sldv:Setup:CreatingScheduledModel',mdlName)));

        obj.clearDiagnosticInterceptor();

        [status,obj.mExtractedModelH,obj.mErrorMsg]=...
        sldvextract(obj.mRootModelH,showModel,obj.mShowUI,true);

        if status


            errorInfo=sldvshareprivate('checkCompatForSLTStubbedSLFunction',obj.mRootModelH,obj.mExtractedModelH);
            if~isempty(errorInfo.identifier)
                sldvshareprivate('avtcgirunsupcollect','push',obj.mRootModelH,'sldv',...
                errorInfo.message,errorInfo.identifier);
                obj.mErrorMsg=sldvshareprivate('avtcgirunsupdialog',obj.mRootModelH,obj.mShowUI);
                status=false;
            end
        end

        if~status
            errorMsg=getString(message('Sldv:Setup:ErrorDetectedInScheduleExtraction',mdlName));
            obj.reportExtractionFailure(errorMsg);
            return;
        end


        obj.setDiagnosticInterceptor();

        ExtractedModel=get_param(obj.mExtractedModelH,'FileName');
        obj.logNewLines(getString(message('Sldv:Setup:NewModelFile',ExtractedModel)));
    end
end


