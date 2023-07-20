function saveExtractedModel(obj)




    extractedModelName=get_param(obj.ModelH,'Name');
    [extractedModelFullPath,testcomp,opts]=getExtractionInfo(obj,extractedModelName,obj.ModelH);
    if~obj.Status
        return;
    end

    obj.PhaseId=2;
    obj.turnOffAndStoreWarningStatus;

    if~obj.IsModelSlicer
        [ableToSaveExtractedMdl,MexFromSave]=Sldv.SubSystemExtract.copyCoverageAndSldvFilterFiles(obj.OrigModelH,...
        opts,...
        obj.BlockH,...
        obj.ModelH,...
        extractedModelFullPath);
        if~ableToSaveExtractedMdl



            msg=getString(message('Sldv:SubSysExtract:ErrSaveExtractMdl'));
            msgid='Sldv:SubSysExtract:ErrSaveExtractMdl';

            ME=MException(msgid,msg);
            ME=ME.addCause(MexFromSave);

            obj.setExtractError(msg,msgid);
            obj.Status=false;
            obj.deriveErrorMsg(ME);

            close_system(obj.ModelH,0);
            obj.ModelH=[];
        end
    else

        if~isempty(get_param(obj.OrigModelH,'CovFilter'))

            set_param(obj.ModelH,'CovFilter','')
        end
    end

    obj.restoreWarningStatus;
    obj.PhaseId=0;

    if~obj.Status
        return;
    end

    if obj.ShowModel
        set_param(obj.ModelH,'Open','on');
    end

    if~isempty(testcomp)
        testcomp.analysisInfo.analyzedModelH=obj.ModelH;
        testcomp.analysisInfo.extractedModelH=obj.ModelH;
        testcomp.analysisInfo.analyzedSubsystemH=obj.BlockH;
    end
end


