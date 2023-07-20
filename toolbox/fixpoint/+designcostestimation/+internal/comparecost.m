function comparecost(modelA,modelB)






    DesignCostResult=runDCEAndGetCost(modelA);
    CostTable=DesignCostResult.CostTable;
    CostTable=filterTable(CostTable);
    save([modelA,'.mat'],'DesignCostResult','CostTable');%#ok<*USENS>

    DesignCostResult=runDCEAndGetCost(modelB);%#ok<*NASGU>
    CostTable=DesignCostResult.CostTable;
    CostTable=filterTable(CostTable);
    save([modelB,'.mat'],'DesignCostResult','CostTable');

    visdiff([modelA,'.mat'],[modelB,'.mat']);
end


function result=runDCEAndGetCost(mdl)
    result=designcostestimation.internal.dce(mdl);
end


function CostTable=filterTable(CostTable)
    toDelete=CostTable.TotalBlockCost==0;
    CostTable(toDelete,:)=[];
end


