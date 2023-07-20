function showUI(obj)









    obj.cacheData(false);





    if isempty(obj.mAnalysisUI)&&~any(isvalid(obj.mAnalysisUI))

        obj.mAnalysisUI=webcfganalysis.AnalysisUI(obj.mBDMgr);
    end
    obj.mAnalysisUI.showUI();

end


