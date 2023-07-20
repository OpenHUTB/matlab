


function computeComponentChecksum(obj)

    if~isempty(obj.mBlockH)&&(~strcmp('off',get_param(obj.mBlockH,'Commented')))
        obj.mTranslationState.ComponentChecksum=[];
        return;
    end

    tChecksumCalculator=Sldv.Compatibility.ChecksumCalculator(obj.mRootModelH,obj.mBlockH);
    [obj.mTranslationState.ComponentChecksum,msg]=tChecksumCalculator.compute();

    if isempty(obj.mTranslationState.ComponentChecksum)
        tMsgID='Sldv:Setup:ChecksumComputationFailed';
        tMsg=msg;
        sldvshareprivate('avtcgirunsupcollect','push',...
        obj.mTestComp.analysisInfo.analyzedModelH,'sldv_warning',tMsg,tMsgID);
    end



    obj.mTranslationState.CustomCodeChecksum=Sldv.Compatibility.ChecksumCalculator.getCustomCodeInfo(obj.mTestComp.analysisInfo.analyzedModelH);

    if obj.mIsXIL



        obj.mTranslationState.XILChecksum=Sldv.Compatibility.ChecksumCalculator.getXilChecksum(obj.mTestComp.analysisInfo.designModelH,...
        SlCov.CovMode.fromString(obj.mTestComp.simMode));
    end
end
