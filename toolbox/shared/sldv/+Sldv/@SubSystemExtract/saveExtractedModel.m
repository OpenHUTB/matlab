function saveExtractedModel(obj)




    extractedModelName=get_param(obj.ModelH,'Name');
    [extractedModelFullPath,testcomp,opts]=getExtractionInfo(obj,extractedModelName,obj.ModelH);
    if~obj.Status
        return;
    end

    obj.PhaseId=2;
    obj.turnOffAndStoreWarningStatus;

    obj.restoreLibLinks;
    obj.fixAtomicSubchartMask;

    if~obj.IsModelSlicer
        ableToSaveExtractedMdl=Sldv.SubSystemExtract.copyCoverageAndSldvFilterFiles(obj.OrigModelH,...
        opts,...
        obj.SubSystemH,...
        obj.ModelH,...
        extractedModelFullPath);
        if~ableToSaveExtractedMdl
            msg=getString(message('Sldv:SubSysExtract:ErrSaveExtractMdl'));
            obj.deriveSsError(msg,'Sldv:SubSysExtract:ErrSaveExtractMdl',obj.ModelH);
            obj.ModelH=[];
            obj.Status=false;
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
        testcomp.analysisInfo.analyzedSubsystemH=obj.SubSystemH;
        testcomp.analysisInfo.analyzedAtomicSubchartWithParam=obj.AtomicSubChartWithParam;
        testcomp.analysisInfo.mappedSfId=...
        containers.Map('KeyType','double','ValueType','double');
        testcomp.analysisInfo.mappedBlockH=...
        containers.Map('KeyType','double','ValueType','double');
    end
end


