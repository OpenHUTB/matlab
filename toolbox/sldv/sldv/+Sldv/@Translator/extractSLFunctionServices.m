function status=extractSLFunctionServices(obj)




    status=true;

    if obj.mSkipTranslation
        return;
    end

    if obj.mRootModelH~=obj.mExtractedModelH




        return;
    end

    [hasMissingFcns,errMsg]=sldvshareprivate('mdl_has_missing_slfunction_defs',obj.mRootModelH);
    if~isempty(errMsg)
        sldvshareprivate('avtcgirunsupcollect','push',obj.mRootModelH,...
        'sldv',errMsg.message,errMsg.identifier);
        obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
    elseif hasMissingFcns
        showModel=false;
        mdlName=get_param(obj.mRootModelH,'name');
        obj.logNewLines(getString(message('Sldv:Setup:CreatingSLFunctionStubModel',mdlName)));

        obj.clearDiagnosticInterceptor();


        oc=onCleanup(@()obj.setDiagnosticInterceptor());

        [status,obj.mExtractedModelH,obj.mErrorMsg]=...
        sldvextract(obj.mRootModelH,showModel,obj.mShowUI,true);

        if~status
            errorMsg=getString(message('Sldv:Setup:ErrorDetectedInSLFunctionStubExtraction',mdlName));
            obj.reportExtractionFailure(errorMsg);
            return;
        end

        delete(oc);

        ExtractedModel=get_param(obj.mExtractedModelH,'FileName');
        obj.logNewLines(getString(message('Sldv:Setup:NewModelFile',ExtractedModel)));
    end
end


