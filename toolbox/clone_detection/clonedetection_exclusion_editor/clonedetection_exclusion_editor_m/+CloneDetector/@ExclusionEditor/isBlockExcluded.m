function[isExcluded]=isBlockExcluded(this,blockSID,blockName)




    isExcluded=false;

    tableData=this.getTableData();

    for ind=1:length(tableData)
        blockDetails=tableData{ind}{1};
        if strcmpi(blockDetails.sid,blockSID)&&...
            strcmpi(blockDetails.name,blockName)
            isExcluded=true;
            return;
        end
    end
end

