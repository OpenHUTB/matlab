function status=setInputCovDataAndFilter(obj)




    obj.mTestComp.analysisInfo.covFilter=[];


    status=obj.setInputCovData();
    if status
        status=obj.setCovFilter();
    end
end
