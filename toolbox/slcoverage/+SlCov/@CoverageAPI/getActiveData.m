function obj=getActiveData(model)






    obj=[];

    coveng=cvi.TopModelCov.getInstance(model);
    if isempty(coveng)
        return;
    end

    obj=coveng.activeData;



    if isempty(obj)
        obj=cvi.ResultsExplorer.ResultsExplorer.findExistingDlg(model);
    end
end