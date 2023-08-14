function updatedDesignVal=RestructureDesignRanges(designVal)







    if iscell(designVal)

        updatedDesignVal=cell2mat(designVal);


        updatedDesignVal=reshape(updatedDesignVal,1,[]);
    else
        updatedDesignVal=designVal;
    end

end

