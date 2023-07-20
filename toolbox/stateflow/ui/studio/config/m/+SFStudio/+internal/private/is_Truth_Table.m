function[isTT,ttObjectId]=is_Truth_Table(cbinfo)




    chartId=SFStudio.Utils.getChartId(cbinfo);
    isTT=false;
    if chartId==0
        ttObjectId=0;
        return;
    end
    if sfprivate('is_truth_table_chart',chartId)
        ttObjectId=chartId;
    else
        ttObjectId=SFStudio.Utils.getMenuTargetOrSubviewerId(cbinfo);
    end

    if~sfprivate('is_truth_table_chart',ttObjectId)&&~sfprivate('is_truth_table_fcn',ttObjectId)
        sfObj=sf('IdToHandle',ttObjectId);
        if isa(sfObj,'Stateflow.Transition')||isa(sfObj,'Stateflow.Junction')
            ttObjectId=sfObj.Subviewer.Id;
            if sfprivate('is_truth_table_fcn',ttObjectId)
                isTT=true;
                return;
            end
        end
    else
        isTT=true;
    end
end
