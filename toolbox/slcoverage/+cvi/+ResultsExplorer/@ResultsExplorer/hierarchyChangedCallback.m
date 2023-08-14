function hierarchyChangedCallback(~,~,obj)







    modelName=getActiveModel(obj);
    if isempty(modelName)
        return;
    end

    curCovRootNode=obj.root.activeTree.root;



    isDataAvailable=~isempty(curCovRootNode.children);
    setOnHarness=true;

    skipIfHarness=true;




    cvi.Informer.markHighlightingAvailable(modelName,isDataAvailable,setOnHarness,skipIfHarness);


    curActiveDataCount=length(curCovRootNode.children);
    if(curActiveDataCount~=obj.lastActiveDataCount)

        [~,res]=SlCov.CovMenus.getInformerDisplayed(modelName);
        if res
            cvi.Informer.close(get_param(modelName,'CoverageId'));
        end

        SlCov.CoverageAPI.setActiveDataNeedsRegen(modelName);
    end
    obj.lastActiveDataCount=curActiveDataCount;
end

