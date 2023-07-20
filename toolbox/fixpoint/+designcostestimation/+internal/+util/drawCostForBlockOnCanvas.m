function drawCostForBlockOnCanvas(BlockName,BlockCost,TotalBlockCost)










    if(BlockCost<1&&TotalBlockCost<1)
        return;
    end


    if(strcmp(get_param(BlockName,'type'),'block_diagram'))
        return;
    end



    set_param(char(BlockName),'AttributesFormatString',['Cost: '...
    ,num2str(BlockCost),'; ','TotalCost: ',num2str(TotalBlockCost)]);
end


