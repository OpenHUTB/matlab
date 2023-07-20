function CheckEntries(block,entriesList,num)




    if length(entriesList)~=num
        DAStudio.error('SimulinkBlocks:upgrade:wrongNumMaskEntries',block);
    end

end
